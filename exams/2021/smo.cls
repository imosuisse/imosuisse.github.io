% Created and maintained by Cyril J. Frei (cyril-jonas@imosuisse.ch)

%%% Usage %%%
%This and the graphics (logos) are the only files needed to compile all imosuisse scripts and exams.
% Either you place these files in the same files as the .tex or at the include path of your TeX Environment. E.g.:
% C:\Users\cfrei\AppData\Roaming\MiKTeX\2.9\tex\latex

% TODO: Explain all the functionality

%%% Hint for LaTeX usage on Windows %%%
% If MikTex doesn't find a file like a graphic or class file in the search path, run (Windows+R, type cmd) following command:
% initexmf --update-fndb

%% Various Hints %%
% To open pdf's in TeXworks which were generate by specifying a new jobname, one needs a script (put it in TeXworks script folder [Check under Scripts->Scripting TexWorks->ShowScriptsFolder], activate in under `Scripts'): 

%// TeXworksScript
%// Title: Open jobname in default viewer
%// Description: Checks after Typeset, whether a jobname was specified. If so, it opens the pdf with that name.
%// Author: Cyril Jonas Frei
%// Version: 0.1.0
%// Date: 2016-05-17
%// Script-Type: hook
%// Hook: AfterTypeset
%var content = TW.target.text;var firstLine = content.split("\n")[0];if(firstLine.search("job-name")>0){var jobName = firstLine.split("=")[1] + ".pdf";retVal = TW.app.openFileFromScript(jobName, TW, -1,true);if (retVal["status"] != 0){TW.information(TW.target, "Error", retVal["message"]);}}undefined;

% it once stopped working. Solution: restart windows...


%%% Changelog %%%
%25 June 14: change margins on titlepage
%26 June 14: change margins on titlepage differently
%26 July 14: change spacing on titelpage (table of contens has more space now)
%26 July 14: changed option processing. Warning 'unused option' should be fixed
%26 July 14: added makebox to the logo. Solves overfull hbox
%17 August 14: commented the use of titlepage. Was necessary to avoid new page when style=exercise
%17 August 14: changed commands \beginner etc. to use \subsection*. 
%25 August 14: changed exercise0 environement
%10 October 14: changed size to 11pt
%17 October 14: added exercise4 environement
%19 October 14: changed logo and some spacing around it (only german version yet...)
%20 October 14: changed vspace before logo, fixed missing ] with logo
%24 October 14: changed fr and it logo.
%27 October 14: added italian \beginner commands
%27 October 14: (Louis) changed some mistakes in french words
%09 January 15: changed default option of titlepage to no
%09 January 15: added style=exam
%10 January 15: added style=solution
%11 January 15: added (examtime, examdate, place) to style exam
%18 February 15: changed shortscript fontsize
%18 February 15: changed default for titlepage and style
%19 May 15: added sample style
%06 September 15: added  \oldexercise command
%01 Dezember 15: added \version and added it to the titlepage
%01 Dezember 15: changed shortscript design to include author
%15 January 16: added english as language (with logo)
%02 March 16: added \translation command
%02 March 16: added tikz and xstring packages
%02 March 16: changed variable place to examplace
%02 March 16 added \begin{problemday} environment
%02 March 16: added \translation 
%08 Mai 16: changed language: loads all four languages and selects the apropriate language afterwards (allows to change language mid document)
%19 Mai 16: moved selectLanguage to BeginDocument (interference between french package and enumitem) 
% 19 June 16: updated nologo space
% 19 June 16: Searches the logo at a second place (in the same folder as the .tex)
% 23 June 16: added .pdf extension when including graphics (gives a better error when someone tries to compile with latex instead of pdftex)
% 28 December 16: added \de, \fr, \ita, \en commands (\it is taken by italics)
% 28 December 16: added some hacks with jobname into the classfile (e.g. for \day or automatic language setting)
% 28 December 16: changed exam layout and text
% 28 December 16: added some documentation in this file
% 07 January 17: changed vspace before titel in exam style (more space)
% 09 January 17: changed \kgV to cooparate with all languages
% 01 February 17: added \ifexam arround jobname hacking, such that it doesn't interfere with files like fr-ungleichungen which contain `en' at the end.
% 09 March 17: added exam-preliminary as style option and ifpreliminary, to distinguish between exams of the different levels, to change the text on the exam
% 17 September 17: added the \fi needed because of the new style option
% 20 September 17: added english translations for theorems and problem levels
% 07 January 18: added examtrue to exam-preliminary
% 07 January 18: added some negative space before title when preliminary exam
% 14 March 18: added english translation of gcd, lcm
% 17 April 18: changed translation of ''Satz'' to ''Proposition'' in English and French instead of''Theorem'' 
% 18 April 18: commended environments exercise1-4 to see, whether they are used anywhere. Can be deleted later. Edit: have been deleted
% 18 April 18: changed formatting of the non-starred version of subsection when style=exercise
% 18 April 18: added the exercise list, which resets at section titles.
% 06 June 18: added english translation of \oldexercise
% 03 July 18: added explanations to the `missing style=' error
% 02 Nov 18: added thm-box, bsp-box, ..., which put a frame around the environment
% 02 Nov 18: changed definitions of the theorem environments, such that all languages are defined simultaneously
% 05 Nov 18: changed numbering of theorems if there is no section
% 07 Dec 18: placed the new logo on the exam-preliminary
% 15 Jan 19: defined \oldlogo option 
% 15 Jan 19: modified the language option, so it can take a list as value. Typesets each language which appears in the option 
% 15 Jan 19: fixed the \oldlogo option
% 15 Jan 19: added day={1,2} option 
% 11 Jun 19: added remark enivornment
% 11 Jun 19: changed color of boxes
% 31 Jan 20: changed \day to \examday so that \today prints the correct date
% 01 Jul 20: added hyperref package
% 22 Nov 20: added hyperref setup to get rid of the boxes
% 17 Jan 21: changing processing of titlepage option and tyding up of various spacings (no visual change intended)
% 17 Jan 21: Adapted spacing for new logo for scripts
% 09 Feb 21: Fixed theorem numbering and removed the final . from the numbering.

%TODO: add required version of babel
%TODO: add errors/warnings for style=exam to explain usage

\NeedsTeXFormat{LaTeX2e}[1994/06/01]
\ProvidesClass{smo}[2014/10/24]

\RequirePackage{xkeyval} %having both xkeyval and kvoptions allows for some reason to have { and } in the options
\RequirePackage{kvoptions} %needed for class options like `key = value'
\DeclareStringOption[none]{language}
\DeclareStringOption[1]{day}
\DeclareStringOption[none]{titlepage}
\DeclareStringOption[none]{style}

\DeclareDefaultOption{}

\ProcessKeyvalOptions*

\RequirePackage{pdftexcmds} %required for string comparison

%define if's
\newif\iffrench\frenchfalse\newif\ifgerman\germanfalse\newif\ifitalian\italianfalse\newif\ifenglish\englishfalse\newif\ifall\allfalse
\newif\iftitlepage\titlepagefalse
\newif\iflogo\logotrue \newif\ifoldlogo\oldlogofalse
\newif\ifscript\scriptfalse
\newif\ifexercise\exercisefalse
\newif\ifshortscript\shortscriptfalse
\newif\ifexam\examfalse
\newif\ifsolution\solutionfalse
\newif\ifsample\samplefalse
\newif\ifpreliminary\preliminaryfalse

%process option style
  \ifnum\pdf@strcmp{\smo@style}{script}=0
    \scripttrue
    \titlepagetrue
  \else\ifnum\pdf@strcmp{\smo@style}{exercise}=0
    \exercisetrue
  \else\ifnum\pdf@strcmp{\smo@style}{shortscript}=0
    \shortscripttrue
  \else\ifnum\pdf@strcmp{\smo@style}{exam}=0
    \examtrue
  \else\ifnum\pdf@strcmp{\smo@style}{exam-preliminary}=0
    \examtrue
    \preliminarytrue
  \else\ifnum\pdf@strcmp{\smo@style}{solution}=0
    \solutiontrue
  \else\ifnum\pdf@strcmp{\smo@style}{sample}=0
    \sampletrue
  \else
    \ClassError{smo}{Specify the 'style=' option. Possible values:
      script (titlepage with TOC, 12pt, wide margins),
      shortscript (no titlepage, 12pt, narrow margins),
      exercise (11pt),
      exam (11pt),
      exam-preliminary (11pt),
      solution (11pt),
      sample (11pt)}{}
  \fi\fi\fi\fi\fi\fi\fi

%check if the language option was given.
\ifnum\pdf@strcmp{\smo@language}{none}=0
	\ClassError{smo}{No language specified. Use 'language={<language1>,<language2>,...}' option (possible values: german, french, italian,english).}{}
\fi

%process option titlepage
\ifnum\pdf@strcmp{\smo@titlepage}{yes}=0
	\titlepagetrue\fi
\ifnum\pdf@strcmp{\smo@titlepage}{no}=0
	\titlepagefalse\fi
  
%process option nologo
\DeclareVoidOption{nologo}{\logofalse}
\DeclareVoidOption{oldlogo}{\oldlogotrue}

%load article with the right font-size according to style
\ifscript \PassOptionsToClass{a4paper,12pt}{article} \fi
\ifshortscript \PassOptionsToClass{a4paper,12pt}{article} \fi
\ifexercise \PassOptionsToClass{a4paper,11pt}{article} \fi
\ifexam \PassOptionsToClass{a4paper,11pt}{article}\fi
\ifsolution \PassOptionsToClass{a4paper,11pt}{article}\fi
\ifsample \PassOptionsToClass{a4paper,11pt}{article}\fi
\LoadClass{article} 

%execute all options 
\ProcessKeyvalOptions*

%first package to load
\RequirePackage[l2tabu]{nag} %nags if deprecated stuff is used

%set geometry (for each style)
\ifsolution \RequirePackage [a4paper, left=20mm, right=20mm, top=28.28mm, bottom=28.28mm]{geometry} \fi
\ifexam \RequirePackage [a4paper, left=20mm, right=20mm, top=28.28mm, bottom=28.28mm]{geometry} \fi
\ifscript \RequirePackage[a4paper, left=25.63401mm, right=25.63401mm, top=36.25381mm, bottom=36.25381mm]{geometry} \fi
\ifexercise \RequirePackage[a4paper, left=20mm, right=20mm, top=28.28mm, bottom=28.28mm]{geometry} \fi
\ifshortscript \RequirePackage[a4paper, left=20mm, right=20mm, top=28.28mm, bottom=28.28mm]{geometry} \fi
\ifsample \RequirePackage[a4paper, left=20mm, right=20mm, top=28.28mm, bottom=28.28mm]{geometry} \fi

%load packages
\RequirePackage{parskip} %mark paragraph by vertical space, not by indentation
\RequirePackage[utf8]{inputenc} %needed to write äüöéàè
\RequirePackage[T1]{fontenc} %to write the pdf wit proper symbols
\RequirePackage[ngerman,french,italian,english]{babel} %load all languages. Language will get chosen AtBeginDocument
\RequirePackage{amsmath, amsthm, amssymb} %typical math stuff
\RequirePackage{mathtools}%needed for DeclarePairedDelimiter
\RequirePackage[x11names]{xcolor} %to draw colored boxes
\RequirePackage{graphicx} %needed to include pictures, necessary
\RequirePackage[shortlabels]{enumitem} %needed to write \begin{enumerate][]
\RequirePackage{xstring} %needed for string manipulation for exam creation and check the language option
\RequirePackage{tikz} %needed to draw pictures (mostly for tiles), not necessary
\RequirePackage{hyperref}
\hypersetup{
    colorlinks=true
}
\RequirePackage{xpatch} %needed to fix the . after Theorem 1.1 (https://tex.stackexchange.com/questions/338209/remove-dot-after-theorem-with-amsthm-and-hyperref)

\RequirePackage[tikz]{mdframed} %to draw the boxes around environments
\RequirePackage[absolute]{textpos} %to put the logo. [absolute] means relative to the whole page

\RequirePackage{advdate}

\RequirePackage{environ,xparse} %to redefine document environment. Used to compile all language versions
\let\latexdocument\document
\let\endlatexdocument\enddocument

%Make a new \MyAtBeginDocumnt hook which we can use afterwards (as using \AtBeginDocument multiple times causes problems as other packages are using it)
\makeatletter
\def\MyAtBeginDocument{\g@addto@macro\my@begindocumenthook} 
\let\my@begindocumenthook\@empty
\def\MyResetBeginDocument{\global\let\my@begindocumenthook\@empty}

%redefine \begin{document} \end{document}
\ExplSyntaxOn
\RenewEnviron{document}{ 
  \tl_gset_eq:NN \g_tmpa_tl \BODY  %save the content of the environment into \g_tmpa_tl
  \latexdocument
  %check whether the language option contains german. if so set german true and put the \MyAtBeginDocument part and the \BODY part
  \IfSubStr{\smo@language}{german}{  
  	\germantrue 
  	\IfSubStr{\smo@day}{1}{\def\examday{1} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{2}{\def\examday{2} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{3}{\def\examday{3} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{4}{\def\examday{4} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\germanfalse
  }{}
  \IfSubStr{\smo@language}{french}{
  	\frenchtrue
  	\IfSubStr{\smo@day}{1}{\def\examday{1} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{2}{\def\examday{2} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{3}{\def\examday{3} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{4}{\def\examday{4} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\frenchfalse
  }{}
  \IfSubStr{\smo@language}{italian}{
  	\italiantrue
  	\IfSubStr{\smo@day}{1}{\def\examday{1} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{2}{\def\examday{2} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{3}{\def\examday{3} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{4}{\def\examday{4} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\italianfalse
  }{}
  \IfSubStr{\smo@language}{english}{
  	\englishtrue
  	\IfSubStr{\smo@day}{1}{\def\examday{1} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{2}{\def\examday{2} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{3}{\def\examday{3} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\IfSubStr{\smo@day}{4}{\def\examday{4} \my@begindocumenthook \g_tmpa_tl \newpage}{}
  	\englishfalse
  }{}
  \endlatexdocument
}
\ExplSyntaxOff


%parskip and amsthm fix
\begingroup 
\makeatletter
   \@for\theoremstyle:=definition,remark,plain\do{
     \expandafter\g@addto@macro\csname th@\theoremstyle\endcsname{
        \addtolength\thm@preskip\parskip
     }
   }
\endgroup

%useful command for multiple languages:
\newcommand{\translation}[3]{\ifgerman#1\fi \iffrench#2\fi  \ifitalian#3\fi} %deprecated
\newcommand{\de}[1]{\ifgerman#1\fi}
\newcommand{\fr}[1]{\iffrench#1\fi}
\newcommand{\ita}[1]{\ifitalian#1\fi}
\newcommand{\en}[1]{\ifenglish#1\fi}

%if exercise: change section title
\ifexercise
\usepackage[explicit]{titlesec}
\titleformat{\section}[frame]{\vspace{1cm}}{}{8pt}{\Large\bfseries\filcenter\thesection{ }#1}[\restartlist{exercise}]%automatically reset the exercise enumeration
\titleformat{name=\subsection}[block]{\vspace{1cm}}{}{0pt}{\normalfont\large\bfseries\filcenter#1\hrule}[\vspace{-1cm}]%non-starred: it's in the middle, without number, with horizontal line
\titleformat{name=\subsection,numberless}{\normalfont\large\bfseries}{#1}{1em}{}%starred: default for subsection

%if exercise: add new commands
\newcommand{\beginner}{\subsection*{\de{Einstieg}\fr{Mise en jambes}\ita{Einstieg?}\en{Beginner}}}
\newcommand{\intermediate}{\subsection*{\de{Fortgeschritten}\fr{Avancé}\ita{Fortgeschritten?}\en{Intermediate}}}
\newcommand{\olympiad}{\subsection*{\de{Olympiade}\fr{Olympiade}\ita{Olympiade?}\en{Olympiad}}}

\ifgerman \newcommand{\oldexercise}{\section{Aufgaben aus vergangenen Olympiaden}
Alte Prüfungsaufgaben sind für die Vorbereitung sehr geeignet; einerseits entsprechen sie natürlich dem Prüfungsniveau, und andererseits sind alle Lösungen zu den Aufgaben auf unserer Homepage \texttt{www.imosuisse.ch} zu finden. Man sollte jedoch immer zuerst selbst an den Aufgaben gearbeitet haben, bevor man sich die Musterlösungen dazu anschaut!}\fi
\iffrench \newcommand{\oldexercise}{\section{Exercices d'Olympiades précédentes}
Les exercices des olympiades passées sont d'excellents entrainements pour l'examen. Tu en trouveras d'autres, leur solution, ainsi que l'ensemble des anciens examens sur \texttt{www.imosuisse.ch}. Il est par contre très important pour toi de longuement essayer avant d'aller consulter la solution !}\fi
\ifitalian \newcommand{\oldexercise}{
}\fi
\ifenglish \newcommand{\oldexercise}{\section{Exercises from Previous Olympiads}
Questions from past olympiads are excellent preparation materials: they are of course at the correct level of difficulty, and additionally, all solutions can be found on \texttt{www.imosuisse.ch}. But make sure to give the problems a good try before looking up the solutions!}\fi

% if exercise: Define new enumerations TODO: remove the right ones
\newlist{exercise}{enumerate}{1}
\setlist[exercise,1]{%
  label=\thesection.\arabic*,
  itemsep=1em,
  resume=exercise
}
\newlist{exercise0}{enumerate}{1}
\setlist[exercise0,1]{%
  label=\thesection.\arabic*,
  itemsep=1em
}
\fi %end of ifexercise


%define enivornements
\theoremstyle{plain}
\newtheorem{thm}{\de{Theorem}\fr{Théorème}\ita{Teorema}\en{Theorem}}[section]
\newtheorem{thm-box}[thm]{\de{Theorem}\fr{Théorème}\ita{Teorema}\en{Theorem}}
\newtheorem{satz}[thm]{\de{Satz}\fr{Proposition}\ita{Teorema}\en{Proposition}}
\newtheorem{satz-box}[thm]{\de{Satz}\fr{Proposition}\ita{Teorema}\en{Proposition}}
\newtheorem{lem}[thm]{\de{Lemma}\fr{Lemme}\ita{Lemma}\en{Lemma}}
\newtheorem{lem-box}[thm]{\de{Lemma}\fr{Lemme}\ita{Lemma}\en{Lemma}}
\newtheorem{cor}[thm]{\de{Korollar}\fr{Corollaire}\ita{Corollario}\en{Corollary}}
\newtheorem{cor-box}[thm]{\de{Korollar}\fr{Corollaire}\ita{Corollario}\en{Corollary}}
\newtheorem{alg}[thm]{\de{Algorithmus}\fr{Algorithme}\ita{Algoritmo}\en{Algorithm}}
\newtheorem{alg-box}[thm]{\de{Algorithmus}\fr{Algorithme}\ita{Algoritmo}\en{Algorithm}}
\newtheorem{bsp}{\de{Beispiel}\fr{Exemple}\ita{Esempio}\en{Example}}
\newtheorem{bsp-box}[bsp]{\de{Beispiel}\fr{Exemple}\ita{Esempio}\en{Example}}
\newtheorem*{rem}{\de{Bemerkung}\fr{Remarque}\ita{Osservazione}\en{Remark}}
\newtheorem*{rem-box}{\de{Bemerkung}\fr{Remarque}\ita{Osservazione}\en{Remark}}
\newtheorem*{bem}{\de{Bemerkung}\fr{Remarque}\ita{Osservazione}\en{Remark}}
\newtheorem*{bem-box}{\de{Bemerkung}\fr{Remarque}\ita{Osservazione}\en{Remark}}
\theoremstyle{definition}
\newtheorem{defn}{\de{Definition}\fr{Définition}\ita{Definizione}\en{Definition}}[section]
\newtheorem{defn-box}[defn]{\de{Definition}\fr{Définition}\ita{Definizione}\en{Definition}}

%change numbering if there is no section, so it doesn't print as Theorem 0.1
\renewcommand{\thethm}{%
\ifnum\value{section}=0 
%\thechapter% "no section"
\else
\thesection.% at least within a section
\fi%
\arabic{thm}}

\surroundwithmdframed[linewidth=0.7pt,backgroundcolor= Burlywood1,roundcorner = 0.5pt,skipabove=11pt
]{thm-box}
\surroundwithmdframed[linewidth=0.7pt,backgroundcolor= Burlywood1,roundcorner = 0.5pt,skipabove=11pt
]{satz-box}
\surroundwithmdframed[linewidth=0.7pt,backgroundcolor= Burlywood1,roundcorner = 0.5pt,skipabove=11pt
]{lem-box}
\surroundwithmdframed[linewidth=0.7pt,backgroundcolor= Burlywood1,roundcorner = 0.5pt,skipabove=11pt
]{cor-box}
\surroundwithmdframed[linewidth=0.7pt,backgroundcolor= black!10,roundcorner = 0.5pt,skipabove=11pt
]{alg-box}
\surroundwithmdframed[linewidth=0.7pt,backgroundcolor= DarkSeaGreen1,roundcorner = 0.5pt,skipabove=11pt
]{bsp-box}
\surroundwithmdframed[linewidth=0.7pt,backgroundcolor= AntiqueWhite1,roundcorner = 0.5pt,skipabove=11pt
]{defn-box}
\surroundwithmdframed[linewidth=0.7pt,backgroundcolor= blue!10,roundcorner = 0.5pt,skipabove=11pt
]{bem-box}
\surroundwithmdframed[linewidth=0.7pt,backgroundcolor= blue!10,roundcorner = 0.5pt,skipabove=11pt
]{rem-box}

%define new commands
\DeclareMathOperator{\ggT}{\de{ggT}\fr{pgcd}\ita{mcd}\en{gcd}}
\DeclareMathOperator{\pgcd}{\de{ggT}\fr{pgcd}\ita{mcd}\en{gcd}}
\DeclareMathOperator{\mcd}{\de{ggT}\fr{pgcd}\ita{mcd}\en{gcd}}
\let\gcd\relax
\DeclareMathOperator{\gcd}{\de{ggT}\fr{pgcd}\ita{mcd}\en{gcd}}
\DeclareMathOperator{\kgV}{\de{kgV}\fr{ppcm}\ita{mcm}\en{lcm}}
\DeclareMathOperator{\ppcm}{\de{kgV}\fr{ppcm}\ita{mcm}\en{lcm}}
\DeclareMathOperator{\mcm}{\de{kgV}\fr{ppcm}\ita{mcm}\en{lcm}}
\let\lcm\relax
\DeclareMathOperator{\lcm}{\de{kgV}\fr{ppcm}\ita{mcm}\en{lcm}}
\DeclareMathOperator{\ord}{ord}
\DeclarePairedDelimiter\abs{\lvert}{\rvert}
\DeclarePairedDelimiter\floor{\lfloor}{\rfloor}
\DeclarePairedDelimiter\frack{\{}{\}}

\newcommand{\nequiv}{\not \equiv}
\newcommand{\ndiv}{\mathopen{\mathchoice{\not{|}\,}{\not{|}\,}{\!\not{\:|}}{\not{|}}}}
\newcommand{\R}{\mathbb{R}}
\newcommand{\N}{\mathbb{N}}
\newcommand{\Z}{\mathbb{Z}}
\newcommand{\Q}{\mathbb{Q}}
\newcommand{\C}{\mathbb{C}}

%commands for exams in 1 document
\newcounter{examdaycounter}
\setcounter{examdaycounter}{1}
\newsavebox{\examdaybox}
\newenvironment{problemday}{%
%\newgeometry{left=2cm,right=2cm,nohead,nofoot}
\setbox\examdaybox=\vbox\bgroup%
}%
{%
\egroup
\IfStrEq*{\examday}{\theexamdaycounter}{\usebox{\examdaybox}}{}%
\stepcounter{examdaycounter}%
}

%make existing commands prettier
\renewcommand{\phi}{\varphi} %non capital phi
\renewcommand{\div}{\, | \,}

%set default author to empty
\let\@author\@empty

%define new variables
\let\@version\relax
\def\version#1{\def\@version{#1}}
\let\@examdate\relax
\def\examdate#1{\def\@examdate{#1}}
\let\@place\relax
\def\place#1{\def\@place{#1}}
\let\@examplace\relax
\def\examplace#1{\def\@examplace{#1}}
\let\@examtime\relax
\def\examtime#1{\def\@examtime{#1}}


%%%%%%%%%%%%%%%% At Begin of Document %%%%%%%%%%%%%%%%%%%%


\MyAtBeginDocument{ %Start AtBeginDocument
% remove . after Theorem 1.1
\xpatchcmd{\@thm}{\thm@headpunct{.}}{\thm@headpunct{}}{}{}

%checks the jobname (can be specifies by %& -job-name=vorrunde_2017_en-1 in the first line of the .tex), whether there is a language encoded. If yes it changes the languages appropriatly.
\ifexam
\StrRight{\jobname}{4}[\mystring]
\IfSubStr*{\mystring}{fr}{\germanfalse \frenchtrue \italianfalse \englishfalse}{}
\IfSubStr*{\mystring}{de}{\germantrue \frenchfalse \italianfalse \englishfalse}{}
\IfSubStr*{\mystring}{it}{\germanfalse \frenchfalse \italiantrue \englishfalse}{}
\IfSubStr*{\mystring}{en}{\germanfalse \frenchfalse \italianfalse \englishtrue}{}
\ifx\examday\empty
	\StrRight{\jobname}{1}[\examday]
\else \fi
\fi

%change the language of babel to the current one. This corrects different punctuation in different languages. (needs to be here and not in the preamble, because of the french package which interferes with enumitem package)
\ifgerman \selectlanguage{ngerman}\fi
\iffrench \selectlanguage{french}\fi
\ifitalian \selectlanguage{italian}\fi
\ifenglish \selectlanguage{english}\fi

%if titlepage: make more space for table of contents, no page number
\iftitlepage \advance\vsize by 2cm \thispagestyle{empty} \fi


%insert logo (or placeholder if 'nologo' is given)
\iflogo	
	\iffalse %typeset guides
		\begin{textblock*}{\paperwidth-1cm}(0cm,1cm) %{width}(horizontal, vertical)
		\hrule width 20cm
		\end{textblock*}
		
		\begin{textblock*}{\paperwidth-1cm}(2.95cm,2cm) %{width}(horizontal, vertical)
		\vrule height 200pt
		\end{textblock*}
		
		\begin{textblock*}{\paperwidth-1cm}(0.5cm,0.5cm) %{width}(horizontal, vertical)
		\vrule height 200pt
		\end{textblock*}
		
		\begin{textblock*}{\paperwidth-1cm}(1.5cm,0cm) %{width}(horizontal, vertical)
		\vrule height 1.5cm
		\end{textblock*}
		
		\begin{textblock*}{\paperwidth-1cm}(0cm,1.5cm) %{width}(horizontal, vertical)
		\hrule width 1.5cm
		\end{textblock*}
		
		\begin{textblock*}{\paperwidth-1cm}(0cm,2.7cm) %{width}(horizontal, vertical)
		\hrule width 20cm
		\end{textblock*}
	\fi
	\ifoldlogo
		%compensate for logo
		\vspace*{-2.5cm}
		\ifgerman
		\IfFileExists{graphics/de-smo_logo.pdf}
			{\includegraphics{graphics/de-smo_logo.pdf}}
			{\IfFileExists{de-smo_logo.pdf}
				{\includegraphics[height=2cm]{de-smo_logo.pdf}}
				{\ClassError{smo}{Logo (`de-smo_logo.pdf') is missing! Use option 'nologo' to compile without}{}}
			}
		\fi
		\iffrench
		\IfFileExists{graphics/fr-smo_logo.pdf}
			{\includegraphics{graphics/fr-smo_logo.pdf}}
			{\IfFileExists{fr-smo_logo.pdf}
				{\includegraphics{fr-smo_logo.pdf}}
				{\ClassError{smo}{Logo (`fr-smo_logo.pdf') is missing! Use option 'nologo' to compile without}{}}
			}
		\fi
		\ifitalian
		\IfFileExists{graphics/it-smo_logo.pdf}
			{\includegraphics{graphics/it-smo_logo.pdf}}
			{\IfFileExists{it-smo_logo.pdf}
				{\includegraphics{it-smo_logo.pdf}}
				{\ClassError{smo}{Logo (`it-smo_logo.pdf') is missing! Use option 'nologo' to compile without}{}}
			}
		\fi
		\ifenglish
		\IfFileExists{graphics/en-smo_logo.pdf}
			{\includegraphics{graphics/en-smo_logo.pdf}}
			{\IfFileExists{en-smo_logo.pdf}
				{\includegraphics{en-smo_logo.pdf}}
				{\ClassError{smo}{Logo (`en-smo_logo.pdf') is missing! Use option 'nologo' to compile without}{}}
			}
		\fi
	\else %newlogo
		\ifexam
			\begin{textblock*}{\paperwidth-1cm}(1.6cm,0.48cm) %{width}(horizontal, vertical)
			\includegraphics[scale=0.67]{Logo_Mathematik_CMYK.pdf}
			\end{textblock*}
		\else\ifscript
			\begin{textblock*}{\paperwidth-1cm}(0.6cm,0.3cm) %{width}(horizontal, vertical)
			\includegraphics[scale=1]{Logo_Mathematik_CMYK.pdf}
			\end{textblock*}
		\else
			\begin{textblock*}{\paperwidth-1cm}(0.4cm,0.2cm) %{width}(horizontal, vertical)
			\includegraphics[scale=0.8]{Logo_Mathematik_CMYK.pdf}
			\end{textblock*}		
		\fi\fi
	\fi
\fi
\vspace*{2mm}
\iftitlepage \vspace{1cm} \fi
%
%titlepage design if script
\ifscript
	\begin{center}
	\Huge{\textbf{\@title}}\\
	\if\@author\@empty \else{\vspace{1.5cm} \Large{\@author}\\} \fi
	\vspace{0.5cm}
	\ifgerman \large{Aktualisiert: \today{}}\\ \small{vers. \@version\\} \fi
	\iffrench \large{Actualisé: \today}\\ \small{vers. \@version\\} \fi
	\ifitalian \large{Aggiornato: \today{}}\\ \small{vers. \@version\\} \fi
	\end{center}
	\iftitlepage
		%center table of contents
		\vspace*{\fill}
		\tableofcontents
		\vspace*{\fill} 
		%change the margins back
		\newpage
		\advance\vsize by -2cm
	\fi
\fi
%
%titlepage design if shortscript
\ifshortscript
	\begin{center}
	\Huge{\textbf{\@title}}\\[3mm]
	\if\@author\@empty \else{\vspace{.5cm} \Large{\@author}\\[3mm]} \fi
	\ifgerman \large{Aktualisiert: \today}\\ \small{vers. \@version\\} \fi
	\iffrench \large{Actualisé: \today}\\ \small{vers. \@version\\} \fi
	\ifitalian \large{Aggiornato: \today}\\ \small{vers. \@version\\} \fi
	\vspace{1cm}
	\end{center}
\fi
%
%titlepage design if exam
\ifexam
	\pagestyle{empty}
	\begin{textblock*}{\textwidth}(2cm,1.2cm) %{width}(horizontal, vertical)
	\begin{flushright}
	\Huge\textbf{\@title}\\[1mm]
	\Large\@examplace\\[0.5mm]
	\@examdate
	\end{flushright}
	\end{textblock*}
	\iffalse
		\begin{center}
		%\vspace{5mm}
		%\ifpreliminary{\vspace*{-1cm}}\fi
		{\Huge{\textbf{ \@title}}} \\
		\medskip
		\@examplace\ - \@examdate
		\end{center}
	\fi
	\ifgerman
		\textbf{Zeit:} \@examtime \\
		\textbf{Schwierigkeit:} %
		\ifpreliminary{Die Aufgaben eines Themenbereichs sind der Schwierigkeit nach geordnet.\\}
		\else{Die Aufgaben sind der Schwierigkeit nach geordnet.\\}\fi
		\textbf{Punkte:} Jede Aufgabe ist 7 Punkte wert.
	\fi
	\iffrench
		\textbf{Temps :} \@examtime \\
		\textbf{Difficulté :} %
		\ifpreliminary{Les exercices d'un même thème sont classés selon leur difficulté.\\}
		\else{Les exercices sont classés selon leur difficulté.\\}\fi
		\textbf{Points :} Chaque exercice vaut 7 points.
	\fi
	\ifitalian
		\textbf{Durata :} \@examtime \\
		\textbf{Difficoltà :} %
		\ifpreliminary{Gli esercizi relativi ad ogni tema sono ordinati secondo un ordine crescente di difficoltà. \\}
		\else{???\\}\fi
		\textbf{Punti :} Ogni esercizio vale 7 punti.
	\fi
	\ifenglish
		\textbf{Duration:} \@examtime \\
		\textbf{Difficulty:} %
		\ifpreliminary{The problems within one subject are orderd by difficulty.\\}
		\else{The problems are ordered by difficulty.\\}\fi
		\textbf{Points:} Each problem is worth 7 points.
	\fi
\fi

%titlepage design if solution
\ifsolution
	\begin{center}
	\vspace{5mm}
	{\Huge{\textbf{ \@title}}} \\
	\medskip
	\@examplace\ - \@examdate
	\ifgerman \fi
	\iffrench \fi
	\ifitalian \fi
	\end{center}
	\vspace{10mm}
\fi

%titlepage design if exercise
\ifexercise
	%fix the enumeration of the exercise environment, so it resets at the section (c.f. section formatting)
	\makeatletter
	\preto\section{%
	  \let\enit@resume@series@exercise\@empty
	}
	\makeatother
	\begin{center}
	\LARGE{\textbf{\@title}}\\[3mm]
	\ifgerman \large{Aktualisiert: \today}\\ \small{vers. \@version\\} \fi
	\iffrench \large{Actualisé: \today}\\ \small{vers. \@version\\} \fi
	\ifitalian \large{Aggiornato: \today}\\ \small{vers. \@version\\} \fi
	\end{center}
\fi

%titlepage design if sample
\ifsample
	\pagestyle{empty}
	\begin{center}
	\Huge{\textbf{\@title}}\\[3mm]
	\vspace{1cm}
	\end{center}
\fi
} %End AtBeginDocument
