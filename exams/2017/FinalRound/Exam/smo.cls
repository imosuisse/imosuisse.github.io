% Created and maintained by Cyril J. Frei (cyril-jonas@imosuisse.ch)

%%% Usage %%%
%This and the graphics (logos) are the only files needed to compile all imosuisse scripts and exams.
% Either you place these files in the same files as the .tex or at the include path of your TeX Environment. E.g.:
% C:\Users\cfrei\AppData\Roaming\MiKTeX\2.9\tex\latex

%%% Hint for LaTeX usage on Windows %%%
% If MikTex doesn't find a file like a graphis in the search path, run following command:
% initexmf --update-fndb

%% Various Hints %%
% To open pdf's in TeXworks which were generate by specifying a new jobname, one needs a script (put it in TeXworks script folder, activate in under `Scripts'): 

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
% 09 March 17: added exam-preliminary as style option and preliminary if, to distinguish between exams of the different levels, to change the text on the exam

%TODO: add required version of babel
%TODO: add errors/warnings for style=exam to explain usage
%TODO: think about a solution for different text on exams for different rounds

\NeedsTeXFormat{LaTeX2e}[1994/06/01]
\ProvidesClass{smo}[2014/10/24]

\RequirePackage{kvoptions} %needed for class options like `key = value'
\DeclareStringOption[none]{language}
\DeclareStringOption[none]{titlepage}
\DeclareStringOption[none]{style}

\DeclareDefaultOption{}

\ProcessKeyvalOptions*

\RequirePackage{pdftexcmds} %required for string comparison

%define if's
\newif\iffrench\frenchfalse\newif\ifgerman\germanfalse\newif\ifitalian\italianfalse\newif\ifenglish\englishfalse
\newif\iftitlepage\titlepagetrue
\newif\iflogo\logotrue
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
    \preliminarytrue
  \else\ifnum\pdf@strcmp{\smo@style}{solution}=0
    \solutiontrue
  \else\ifnum\pdf@strcmp{\smo@style}{sample}=0
    \sampletrue
  \else
    \ClassError{smo}{Specify the 'style=' option. Possible values: script, exercise, shortscript, exam, exam-preliminary, solution, sample}{}
  \fi\fi\fi\fi\fi\fi

%process option language
  \ifnum\pdf@strcmp{\smo@language}{german}=0
    \germantrue
  \else\ifnum\pdf@strcmp{\smo@language}{french}=0
    \frenchtrue
  \else\ifnum\pdf@strcmp{\smo@language}{italian}=0
    \italiantrue
  \else\ifnum\pdf@strcmp{\smo@language}{english}=0
    \englishtrue
  \else\ifnum\pdf@strcmp{\smo@language}{none}=0
    \ClassError{smo}{No language specified. Use 'language=' option (possible values: german, french, italian,english)}{}
  \else
    \ClassError{smo}{Invalid language. (possible values: german, french, italian,english)}{}
  \fi\fi\fi\fi\fi

%process option titlepage (could be left out and set titlepage when checking the style)

\ifnum\pdf@strcmp{\smo@titlepage}{yes}=0
  \titlepagetrue\fi
\ifnum\pdf@strcmp{\smo@titlepage}{no}=0
  \titlepagefalse\fi
\ifnum\pdf@strcmp{\smo@style}{script}=0
  \titlepagetrue\fi
\ifnum\pdf@strcmp{\smo@style}{exercise}=0
  \titlepagefalse\fi
\ifnum\pdf@strcmp{\smo@style}{shortscript}=0
  \titlepagefalse\fi
\ifnum\pdf@strcmp{\smo@style}{sample}=0
  \titlepagefalse\fi
          
  
%process option nologo
\DeclareVoidOption{nologo}{\logofalse}

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
\RequirePackage{graphicx} %needed to include pictures, necessary
\RequirePackage[shortlabels]{enumitem} %needed to write \begin{enumerate][]
\RequirePackage{xstring} %needed for string manipulation for exam creation
\RequirePackage{tikz} %needed to draw pictures (mostly for tiles), not necessary

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
\newcommand{\translation}[3]{\ifgerman#1\fi \iffrench#2\fi  \ifitalian#3\fi}
\newcommand{\de}[1]{\ifgerman#1\fi}
\newcommand{\fr}[1]{\iffrench#1\fi}
\newcommand{\ita}[1]{\ifitalian#1\fi}
\newcommand{\en}[1]{\ifenglish#1\fi}

%if exercise: change section title
\ifexercise
\usepackage[explicit]{titlesec}
\titleformat{\section}[frame] 
{\vspace{1cm}}{}{8pt}{\Large\bfseries\filcenter\thesection{ }#1}

%if exercise: add new commands
\ifgerman \newcommand{\beginner}{\subsection*{Einstieg}}\fi
\iffrench \newcommand{\beginner}{\subsection*{Mise en jambes}}\fi
\ifitalian \newcommand{\beginner}{\subsection*{Einstieg?}}\fi
\ifgerman \newcommand{\intermediate}{\subsection*{Fortgeschritten}}\fi
\iffrench \newcommand{\intermediate}{\subsection*{Avancé}}\fi
\ifitalian \newcommand{\intermediate}{\subsection*{Fortgeschritten?}}\fi
\ifgerman \newcommand{\olympiad}{\subsection*{Olympiade}}\fi
\iffrench \newcommand{\olympiad}{\subsection*{Olympiade}}\fi
\ifitalian \newcommand{\olympiad}{\subsection*{Olympiade?}}\fi

\ifgerman \newcommand{\oldexercise}{\section{Aufgaben aus vergangenen Olympiaden}
Alte Prüfungsaufgaben sind für die Vorbereitung sehr geeignet; einerseits entsprechen sie natürlich dem Prüfungsniveau, und andererseits sind alle Lösungen zu den Aufgaben auf der Homepage \texttt{www.imosuisse.ch} zu finden. Man sollte jedoch immer zuerst selbst an den Aufgaben gearbeitet haben, bevor man sich die Musterlösungen dazu anschaut!}\fi
\iffrench \newcommand{\oldexercise}{\section{Exercices d'Olympiades précédentes}
Les exercices des olympiades passées sont d'excellents entrainements pour l'examen. Tu en trouveras d'autres, leur solution, ainsi que l'ensemble des anciens examens sur \texttt{www.imosuisse.ch}. Il est par contre très important pour toi de longuement essayer avant d'aller consulter la solution !}\fi
\ifitalian \newcommand{\oldexercise}{
}\fi

% if exercise: Define new enumerations TODO: remove the right ones
\newlist{exercise0}{enumerate}{1}
\setlist[exercise0,1]{%
  label=\thesection.\arabic*,
  itemsep=1em
}
\newlist{exercise1}{enumerate}{1}
\setlist[exercise1,1]{%
  label=E\arabic*,
  itemsep=1em
}
\newlist{exercise2}{enumerate}{1}
\setlist[exercise2,1]{%
  label=F\arabic*,
  itemsep=1em,
}
\newlist{exercise3}{enumerate}{1}
\setlist[exercise3,1]{%
  label=O\arabic*,
  itemsep=1em,
}
\newlist{exercise4}{enumerate}{1}
\setlist[exercise4,1]{%
  label=\arabic*.,
  itemsep=0.7em }
\fi


%define enivornements
\theoremstyle{plain}
\ifgerman \newtheorem{thm}{Theorem}[section] \fi
\iffrench \newtheorem{thm}{Théorème}[section] \fi
\ifitalian \newtheorem{thm}{Teorema}[section] \fi
\ifgerman \newtheorem{satz}[thm]{Satz} \fi
\iffrench \newtheorem{satz}[thm]{Théorème} \fi
\ifitalian \newtheorem{satz}[thm]{Teorema} \fi
\ifgerman \newtheorem{lem}[thm]{Lemma} \fi
\iffrench \newtheorem{lem}[thm]{Lemme} \fi
\ifitalian \newtheorem{lem}[thm]{Lemma} \fi
\ifgerman \newtheorem{cor}[thm]{Korollar} \fi
\iffrench \newtheorem{cor}[thm]{Corollaire} \fi
\ifitalian \newtheorem{cor}[thm]{Corollario} \fi
\ifgerman \newtheorem{alg}[thm]{Algorithmus} \fi
\iffrench \newtheorem{alg}[thm]{Algorithme} \fi
\ifitalian \newtheorem{alg}[thm]{Algoritmo} \fi
\ifgerman \newtheorem{bsp}{Beispiel} \fi
\iffrench \newtheorem{bsp}{Exemple} \fi
\ifitalian \newtheorem{bsp}{Esempio} \fi
\theoremstyle{definition}
\ifgerman \newtheorem{defn}{Definition}[section] \fi
\iffrench \newtheorem{defn}{Définition}[section] \fi
\ifitalian \newtheorem{defn}{Definizione}[section] \fi

%define new commands
\DeclareMathOperator{\ggT}{\de{ggT}\fr{pgcd}\ita{mcd}\en{gcd}}
\DeclareMathOperator{\pgdc}{\de{ggT}\fr{pgcd}\ita{mcd}\en{gcd}}
\DeclareMathOperator{\mcd}{\de{ggT}\fr{pgcd}\ita{mcd}\en{gcd}}
\DeclareMathOperator{\kgV}{\de{kgV}\fr{ppcm}\ita{mcm}\en{lcm}}
\DeclareMathOperator{\ppmc}{\de{kgV}\fr{ppcm}\ita{mcm}\en{lcm}}
\DeclareMathOperator{\mcm}{\de{kgV}\fr{ppcm}\ita{mcm}\en{lcm}}
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
\newcounter{daycounter}
\setcounter{daycounter}{1}
\newsavebox{\daybox}
\newenvironment{problemday}{%
%\newgeometry{left=2cm,right=2cm,nohead,nofoot}
\setbox\daybox=\vbox\bgroup%
}%
{%
\egroup
\IfStrEq*{\day}{\thedaycounter}{\usebox{\daybox}}{}%
\stepcounter{daycounter}%
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


\AtBeginDocument{ %Start AtBeginDocument

%checks the jobname (can be specifies by %& -job-name=vorrunde_2017_en-1 in the first line of the .tex), whether there is a language encoded. If yes it changes the languages appropriatly.
\ifexam
\StrRight{\jobname}{4}[\mystring]
\IfSubStr*{\mystring}{fr}{\germanfalse \frenchtrue \italianfalse \englishfalse}{}
\IfSubStr*{\mystring}{de}{\germantrue \frenchfalse \italianfalse \englishfalse}{}
\IfSubStr*{\mystring}{it}{\germanfalse \frenchfalse \italiantrue \englishfalse}{}
\IfSubStr*{\mystring}{en}{\germanfalse \frenchfalse \italianfalse \englishtrue}{}
\StrRight{\jobname}{1}[\day]
\fi

%change the language of babel to the current one. This corrects different punctuation in different languages. (needs to be here and not in the preamble, because of the french package which interferes with enumitem package)
\ifgerman \selectlanguage{ngerman}\fi
\iffrench \selectlanguage{french}\fi
\ifitalian \selectlanguage{italian}\fi
\ifenglish \selectlanguage{english}\fi

%if titlepage: make more space for table of contents, no page number
\iftitlepage \advance\vsize by 2cm \thispagestyle{empty} \fi
%compensate for logo
\vspace*{-2.5cm}

%insert logo (or placeholder if 'nologo' is given)
\iflogo
\ifgerman
\IfFileExists{graphics/de-smo_logo.pdf}
	{\includegraphics{graphics/de-smo_logo.pdf}}
	{\IfFileExists{de-smo_logo.pdf}
		{\includegraphics{de-smo_logo.pdf}}
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
\else
\leavevmode \vspace{2.13cm} %needs to be updated! Not anymore?
\fi
\vspace{0.5cm}
\iftitlepage \vspace{1cm} \fi

%titlepage design if script
\ifscript
\begin{center}
\Huge{\textbf{\@title}}\\
\if\@author\@empty \else{\vspace{1.5cm} \Large{\@author}\\} \fi
\vspace{0.5cm}
\ifgerman \large{Aktualisiert: \today}\\ \small{vers. \@version\\} \fi
\iffrench \large{Actualisé: \today}\\ \small{vers. \@version\\} \fi
\ifitalian \large{Aggiornato: \today}\\ \small{vers. \@version\\} \fi
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

%titlepage design if exam
\ifexam
\pagestyle{empty}
\begin{center}
%\vspace{5mm}
{\Huge{\textbf{ \@title}}} \\
\medskip
\@examplace\ - \@examdate
\end{center}
\ifgerman
\textbf{Zeit:} \@examtime \\
\textbf{Schwierigkeit:} %
\ifpreliminary{Die Aufgaben eines Themenbereichs sind der Schwierigkeit nach geordnet.\\}
\else{Die Aufgaben sind der Schwierigkeit nach geordnet.\\}\fi
\textbf{Punkte:} Jede Aufgabe ist 7 Punkte wert. \fi
\iffrench
\textbf{Temps :} \@examtime \\
\textbf{Difficulté :} %
\ifpreliminary{Les exercices d'un même thème sont classés selon leur difficulté.\\}
\else{Les exercices sont classés selon leur difficulté.\\}\fi
\textbf{Points :} Chaque exercice vaut 7 points. \fi
\ifitalian
\textbf{Durata :} \@examtime \\
\textbf{Difficoltà :} %
\ifpreliminary{Gli esercizi relativi ad ogni tema sono ordinati secondo un ordine crescente di difficoltà. \\}
\else{???\\}\fi
\textbf{Punti :} Ogni esercizio vale 7 punti. \fi
\ifenglish
\textbf{Duration:} \@examtime \\
\textbf{Difficulty:} %
\ifpreliminary{The problems within one subject are orderd by difficulty.\\}
\else{The problems are orderd by difficulty.\\}\fi
\textbf{Points:} Each problem is worth 7 points. \fi
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