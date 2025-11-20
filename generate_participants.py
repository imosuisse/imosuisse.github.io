#!/usr/bin/env python3
"""
Script to generate participant files from exam participants.
Collects all unique participants from _exams/*.md files and creates individual
participant files in _participants/ directory with their complete exam history.
"""

import os
import re
import yaml
import unicodedata
from pathlib import Path
from collections import defaultdict


def slugify_name(first_name, last_name):
    """Create a kebab-case slug from first and last name, replacing special characters."""
    name = f"{first_name}-{last_name}".lower()
    
    # Normalize unicode characters to their ASCII equivalents
    # NFD = decompose, then filter out combining marks, then recompose
    name = unicodedata.normalize('NFD', name)
    name = ''.join(char for char in name if unicodedata.category(char) != 'Mn')
    
    # Replace spaces and underscores with hyphens
    name = re.sub(r'[\s_]+', '-', name)
    
    # Remove any remaining non-alphanumeric characters except hyphens
    name = re.sub(r'[^a-z0-9-]', '', name)
    
    # Remove duplicate hyphens
    name = re.sub(r'-+', '-', name)
    
    # Remove leading/trailing hyphens
    name = name.strip('-')
    
    return name


def parse_exam_file(filepath):
    """Parse an exam markdown file and extract participant data."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract YAML front matter
    match = re.match(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
    if not match:
        return None
    
    yaml_content = match.group(1)
    data = yaml.safe_load(yaml_content)
    
    return data


def load_problems_data():
    """Load all problem files and create mapping for lookup."""
    problems_dir = Path('_problems')
    problems_by_year_round = defaultdict(lambda: defaultdict(list))
    
    for problem_file in problems_dir.glob('*.html'):
        try:
            with open(problem_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract YAML front matter
            match = re.match(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
            if not match:
                continue
            
            yaml_content = match.group(1)
            data = yaml.safe_load(yaml_content)
            
            year = data.get('year')
            round_name = data.get('round')
            topic = data.get('topic')
            number = data.get('number')
            
            if year and round_name and topic:
                problems_by_year_round[year][round_name].append({
                    'number': number,
                    'topic': topic,
                    'filename': problem_file.name
                })
        except Exception as e:
            print(f"Warning: Could not parse {problem_file}: {e}")
            continue
    
    # Sort problems by filename within each year/round
    for year in problems_by_year_round:
        for round_name in problems_by_year_round[year]:
            problems_by_year_round[year][round_name].sort(key=lambda p: p['filename'])
    
    return problems_by_year_round


def main():
    # Load problems data first
    print("Loading problems data...")
    problems_data = load_problems_data()
    
    # Dictionary to store participant data: {slug: participant_info}
    participants_data = defaultdict(lambda: {
        'first_name': None,
        'last_name': None,
        'exams': []
    })
    
    # Dictionary to cache exam metadata by slug
    exams_metadata = {}
    
    # Process all exam files
    exams_dir = Path('_exams')
    exam_files = sorted(exams_dir.glob('*.md'))
    
    print(f"Processing {len(exam_files)} exam files...")
    
    for exam_file in exam_files:
        if exam_file.name.startswith('.'):
            continue
            
        exam_data = parse_exam_file(exam_file)
        if not exam_data or 'participants' not in exam_data:
            continue
        
        # Extract exam metadata
        exam_info = {
            'year': exam_data.get('year'),
            'round': exam_data.get('round'),
            'slug': exam_data.get('slug'),
            'title': exam_data.get('title'),
        }
        
        # Cache exam metadata
        exams_metadata[exam_info['slug']] = exam_info
        
        # Process each participant in this exam
        if exam_data.get('participants') is None:
            print(f"Warning: No participants field in {exam_file}")
            continue
            
        for participant in exam_data['participants']:
            if participant is None:
                print(f"Warning: None participant found in {exam_file}")
                continue
            try:
                first_name = (participant.get('first-name') or '').strip()
                last_name = (participant.get('last-name') or '').strip()
            except AttributeError as e:
                print(f"Error in {exam_file}: {e}")
                print(f"Participant: {participant}")
                raise
            
            if not first_name or not last_name:
                continue
            
            # Create unique slug for this participant
            slug = slugify_name(first_name, last_name)
            
            # Store participant info
            if participants_data[slug]['first_name'] is None:
                participants_data[slug]['first_name'] = first_name
                participants_data[slug]['last_name'] = last_name
            
            # Add this exam participant to participant's history
            # Ensure scores is a list for YAML array formatting
            scores = participant.get('scores', [])
            if not isinstance(scores, list):
                scores = [scores]
            
            exam_participant = {
                'slug': exam_info['slug'],
                'round': exam_info['round'],
                'scores': scores,
                'total': participant.get('total'),
                'rank': participant.get('rank'),
                # Keep year and round temporarily for sorting
                '_year': exam_info['year'],
                '_round': exam_info['round'],
            }
            
            # Add award if present (from Final Round)
            if 'award' in participant:
                exam_participant['award'] = participant['award']
            
            participants_data[slug]['exams'].append(exam_participant)
            
            # Mark if this participant has been in Final Round or Selection
            if exam_file.stem.endswith('-3') or exam_file.stem.endswith('-4'):
                participants_data[slug]['has_qualifying_exam'] = True
    
    # Create _participants directory if it doesn't exist, clear it if it does
    participants_dir = Path('_participants')
    if participants_dir.exists():
        for file in participants_dir.glob('*.md'):
            file.unlink()
    participants_dir.mkdir(exist_ok=True)
    
    # Filter to only participants who have been in Final Round (-3) or Selection (-4)
    filtered_participants = {
        slug: data for slug, data in participants_data.items()
        if data.get('has_qualifying_exam', False)
    }
    
    # Generate individual participant files
    print(f"\nGenerating {len(filtered_participants)} participant files (filtered for Final Round/Selection only)...")
    
    for slug, data in sorted(filtered_participants.items()):
        # Sort exams by year and round (Second Round, Final Round, then Selection)
        def sort_key(exam):
            year = exam['_year'] or 0
            round_name = exam['_round'] or ''
            # Order: Second Round (1), Final Round (2), Selection (3)
            if 'Second' in round_name:
                round_order = 1
            elif 'Final' in round_name:
                round_order = 2
            elif 'Selection' in round_name:
                round_order = 3
            else:
                round_order = 0
            return (year, round_order)
        
        data['exams'].sort(key=sort_key)
        
        # Calculate statistics before removing temporary fields
        
        # Score distribution by round type: count of each score (0-7) and not attempted ('-')
        # Store as arrays: [count_not_attempted, count_0, count_1, ..., count_7, total_count]
        scores_by_round = {
            'second-round': [0] * 10,  # '-', 0-7, total
            'final-round': [0] * 10,
            'selection': [0] * 10
        }
        
        for exam in data['exams']:
            # Skip exams where rank is '-'
            if str(exam.get('rank')) == '-':
                continue
                
            round_name = exam.get('_round', '')
            round_key = None
            if 'Second' in round_name:
                round_key = 'second-round'
            elif 'Final' in round_name:
                round_key = 'final-round'
            elif 'Selection' in round_name:
                round_key = 'selection'
            
            if round_key:
                for score in exam.get('scores', []):
                    score_str = str(score)
                    if score_str == '-':
                        scores_by_round[round_key][0] += 1  # Index 0 for not attempted
                    elif score_str != '?':
                        try:
                            score_val = int(score_str)
                            if 0 <= score_val <= 7:
                                scores_by_round[round_key][score_val + 1] += 1  # Shift by 1
                        except (ValueError, TypeError):
                            pass
        
        # Calculate totals for each round (sum of all scores including not attempted)
        for round_key in scores_by_round:
            total = sum(scores_by_round[round_key][:9])  # Sum first 9 elements
            scores_by_round[round_key][9] = total
        
        # Years of participation (from temporary _year field)
        years = sorted(set(exam['_year'] for exam in data['exams'] if exam.get('_year')))
        
        # Check for LIE award first
        has_lie = False
        for exam in data['exams']:
            award = exam.get('award')
            if award and str(award).lower() == 'lie':
                has_lie = True
                break
        
        # If participant has LIE, ensure all Final Round and Selection exams have LIE award
        if has_lie:
            for exam in data['exams']:
                round_name = exam.get('_round', '')
                if 'Final' in round_name or 'Selection' in round_name:
                    # Set award to LIE if not already set or if it's a medal
                    current_award = exam.get('award')
                    if current_award in [None, '?'] or str(current_award).lower() in ['gold', 'silver', 'bronze']:
                        exam['award'] = 'LIE'
        
        # Awards (medals and qualifications) - lists of years when each award was received
        awards = {
            'gold': [],
            'silver': [],
            'bronze': [],
            'imo': [],
            'memo': []
        }
        
        for exam in data['exams']:
            award = exam.get('award')
            year = exam.get('_year')
            if award and award not in ['?', None] and year:
                award_str = str(award).lower()
                if award_str == 'lie':
                    # Don't add LIE to awards lists
                    continue
                elif award_str in awards:
                    awards[award_str].append(year)
        
        # Calculate total scores across all rounds
        total_scores = [0] * 10
        for round_name in ['second-round', 'final-round', 'selection']:
            for i in range(10):
                total_scores[i] += scores_by_round[round_name][i]
        
        # Calculate topic scores (Algebra, Geometry, Combinatorics, Number Theory)
        # Store as arrays: [algebra, geometry, combinatorics, number_theory, total]
        topics_by_round = {
            'second-round': [0, 0, 0, 0, 0],
            'final-round': [0, 0, 0, 0, 0],
            'selection': [0, 0, 0, 0, 0]
        }
        
        for exam in data['exams']:
            # Skip exams where rank is '-'
            if str(exam.get('rank')) == '-':
                continue
                
            # Lookup exam metadata from cache
            exam_meta = exams_metadata.get(exam['slug'])
            if not exam_meta:
                continue
            
            year = exam_meta['year']
            round_name = exam_meta['round']
            
            # Get problems for this exam
            problems = problems_data.get(year, {}).get(round_name, [])
            
            if not problems:
                continue
            
            # Determine round key
            round_key = None
            if 'Second' in round_name:
                round_key = 'second-round'
            elif 'Final' in round_name:
                round_key = 'final-round'
            elif 'Selection' in round_name:
                round_key = 'selection'
            
            if not round_key:
                continue
            
            # Map scores to problems and accumulate by topic
            for idx, score in enumerate(exam.get('scores', [])):
                if idx >= len(problems):
                    break
                
                problem = problems[idx]
                topic = problem['topic']
                
                # Skip non-numeric scores
                try:
                    score_val = int(score)
                except (ValueError, TypeError):
                    continue
                
                # Map topic to index: 0=Algebra, 1=Geometry, 2=Combinatorics, 3=Number Theory
                topic_idx = None
                if topic == 'Algebra':
                    topic_idx = 0
                elif topic == 'Geometry':
                    topic_idx = 1
                elif topic == 'Combinatorics':
                    topic_idx = 2
                elif topic == 'Number Theory':
                    topic_idx = 3
                
                if topic_idx is not None:
                    topics_by_round[round_key][topic_idx] += score_val
                    topics_by_round[round_key][4] += score_val  # total
        
        # Calculate overall topic totals
        total_topics = [0, 0, 0, 0, 0]
        for round_key in ['second-round', 'final-round', 'selection']:
            for i in range(5):
                total_topics[i] += topics_by_round[round_key][i]
        
        # Calculate best ranks for each round type (second, final, selection)
        # best-ranks: [best_second_round_rank, best_final_round_rank, best_selection_rank]
        # Use None if never participated in that round
        best_ranks = [None, None, None]
        
        for exam in data['exams']:
            round_name = exam.get('_round', '')
            rank = exam.get('rank')
            
            # Skip if rank is not a valid number
            if rank in [None, '?', '-']:
                continue
            
            try:
                rank_val = int(rank)
            except (ValueError, TypeError):
                continue
            
            # Determine which round type
            round_idx = None
            if 'Second' in round_name:
                round_idx = 0
            elif 'Final' in round_name:
                round_idx = 1
            elif 'Selection' in round_name:
                round_idx = 2
            
            if round_idx is not None:
                if best_ranks[round_idx] is None or rank_val < best_ranks[round_idx]:
                    best_ranks[round_idx] = rank_val
        
        # Remove temporary sorting fields
        for exam in data['exams']:
            exam.pop('_year', None)
            exam.pop('_round', None)
        
        # Create order field: remove 'de' prefix from last name if present
        last_name_for_sort = data['last_name']
        if last_name_for_sort.lower().startswith('de '):
            last_name_for_sort = last_name_for_sort[3:]
        order_value = f"{last_name_for_sort}-{data['first_name']}"
        
        # Create YAML content (using kebab-case for field names)
        participant_yaml = {
            'layout': 'participant',
            'first-name': data['first_name'],
            'last-name': data['last_name'],
            'slug': slug,
            'order': order_value,
            'years': years,
            'scores': scores_by_round,
            'total-scores': total_scores,
            'topics': topics_by_round,
            'total-topics': total_topics,
            'best-ranks': best_ranks,
            'awards': awards,
            'exams': data['exams']
        }
        
        # Add LIE field if applicable
        if has_lie:
            participant_yaml['lie'] = True
        
        # Generate markdown file with YAML front matter
        output_file = participants_dir / f"{slug}.md"
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write('---\n')
            
            # Write metadata (using kebab-case)
            f.write(f"layout: {participant_yaml['layout']}\n")
            # Quote special values in names
            first_name = participant_yaml['first-name']
            last_name = participant_yaml['last-name']
            if str(first_name) in ['?', '-']:
                first_name = f"'{first_name}'"
            if str(last_name) in ['?', '-']:
                last_name = f"'{last_name}'"
            f.write(f"first-name: {first_name}\n")
            f.write(f"last-name: {last_name}\n")
            f.write(f"slug: {participant_yaml['slug']}\n")
            f.write(f"order: {participant_yaml['order']}\n")
            
            # Write years
            years_str = '[' + ', '.join(str(y) for y in participant_yaml['years']) + ']'
            f.write(f"years: {years_str}\n")
            
            # Write score distribution as nested array (4 rows x 9 values each)
            # Order: second-round, final-round, selection, total
            f.write("scores:\n")
            scores_data = participant_yaml['scores']
            for round_name in ['second-round', 'final-round', 'selection']:
                score_array = scores_data[round_name]
                scores_str = '[' + ', '.join(str(count) for count in score_array) + ']'
                f.write(f"  - {scores_str}\n")
            # Write total scores as fourth row
            total_scores = participant_yaml['total-scores']
            total_str = '[' + ', '.join(str(count) for count in total_scores) + ']'
            f.write(f"  - {total_str}\n")
            
            # Write topic distribution as nested array (4 rows x 5 values each)
            # Order: second-round, final-round, selection, total
            # Each row: [algebra, geometry, combinatorics, number-theory, total]
            f.write("topics:\n")
            topics_data = participant_yaml['topics']
            for round_name in ['second-round', 'final-round', 'selection']:
                topic_array = topics_data[round_name]
                topics_str = '[' + ', '.join(str(count) for count in topic_array) + ']'
                f.write(f"  - {topics_str}\n")
            # Write total topics as fourth row
            total_topics = participant_yaml['total-topics']
            total_topics_str = '[' + ', '.join(str(count) for count in total_topics) + ']'
            f.write(f"  - {total_topics_str}\n")
            
            # Write best ranks
            best_ranks = participant_yaml['best-ranks']
            # Format None as null in YAML
            ranks_str = '[' + ', '.join('null' if r is None else str(r) for r in best_ranks) + ']'
            f.write(f"best-ranks: {ranks_str}\n")
            
            # Write LIE field if present
            if 'lie' in participant_yaml:
                f.write(f"lie: {str(participant_yaml['lie']).lower()}\n")
            
            # Write awards (only non-empty lists)
            awards = participant_yaml['awards']
            award_items = [f"{k}: [{', '.join(str(y) for y in v)}]" for k, v in awards.items() if v]
            if award_items:
                f.write("awards: {" + ", ".join(award_items) + "}\n")
            else:
                f.write("awards: {}\n")
            
            f.write("exams:\n")
            
            # Write each exam with scores as inline array
            for exam in participant_yaml['exams']:
                f.write(f"  - slug: {exam['slug']}\n")
                f.write(f"    round: {exam['round']}\n")
                # Format scores as inline YAML array, quote special characters
                def format_score(s):
                    s_str = str(s)
                    if s_str in ['-', '?']:
                        return f"'{s_str}'"
                    return s_str
                scores_str = '[' + ', '.join(format_score(s) for s in exam['scores']) + ']'
                f.write(f"    scores: {scores_str}\n")
                # Quote ? and - in total and rank as well
                total_val = f"'{exam['total']}'" if str(exam['total']) in ['?', '-'] else exam['total']
                rank_val = f"'{exam['rank']}'" if str(exam['rank']) in ['?', '-'] else exam['rank']
                f.write(f"    total: {total_val}\n")
                f.write(f"    rank: {rank_val}\n")
                if 'award' in exam:
                    award = exam['award']
                    # Only write award if it's not null
                    if award is not None:
                        if str(award) == '?':
                            award_val = "'?'"
                        else:
                            award_val = award
                        f.write(f"    award: {award_val}\n")
            
            f.write('---\n')
        
        print(f"  Created: {output_file.name} ({len(data['exams'])} exams)")
    
    print(f"\n✅ Successfully generated {len(filtered_participants)} participant files!")
    print(f"   Output directory: {participants_dir.absolute()}")
    print(f"   (Filtered from {len(participants_data)} total participants - only including Final Round/Selection)")


if __name__ == '__main__':
    main()
