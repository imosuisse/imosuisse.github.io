% Created and maintained by Cyril J. Frei (cyril-jonas@imosuisse.ch)

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

%TODO: add required version of babel

\NeedsTeXFormat{LaTeX2e}[1994/06/01]
\ProvidesClass{smo}[2014/10/24]

\RequirePackage{kvoptions}
\DeclareStringOption[none]{language}
\DeclareStringOption[none]{titlepage}
\DeclareStringOption[none]{style}

\DeclareDefaultOption{}

\ProcessKeyvalOptions*

\RequirePackage{pdftexcmds} %required for string comparing

%define if's
\newif\iffrench\frenchfalse\newif\ifgerman\germanfalse\newif\ifitalian\italianfalse
\newif\iftitlepage\titlepagetrue
\newif\iflogo\logotrue
\newif\ifscript\scriptfalse\newif\ifexercise\exercisefalse
\newif\ifshortscript\shortscriptfalse\newif\ifexam\examfalse\newif\ifsolution\solutionfalse

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
  \else\ifnum\pdf@strcmp{\smo@style}{solution}=0
    \solutiontrue
  \else
    \ClassError{smo}{Specify the 'style=' option. Possible values: script, exercise, shortscript, exam, solution}{}
  \fi\fi\fi\fi\fi

%process option language
  \ifnum\pdf@strcmp{\smo@language}{german}=0
    \germantrue
  \else\ifnum\pdf@strcmp{\smo@language}{french}=0
    \frenchtrue
  \else\ifnum\pdf@strcmp{\smo@language}{italian}=0
    \italiantrue
  \else\ifnum\pdf@strcmp{\smo@language}{none}=0
    \ClassError{smo}{No language specified. Use 'language=' option}{}
  \else
    \ClassError{smo}{Invalid language}{}
  \fi\fi\fi\fi

%process option titlepage (could be left out and set titlepage when checking the style)

  \ifnum\pdf@strcmp{\smo@titlepage}{yes}=0
    \titlepagetrue
  \else
    \ifnum\pdf@strcmp{\smo@titlepage}{no}=0
      \titlepagefalse
    \else
      \ifnum\pdf@strcmp{\smo@style}{script}=0
        \titlepagetrue
      \else
        \ifnum\pdf@strcmp{\smo@style}{exercise}=0
          \titlepagefalse
        \else
          \ifnum\pdf@strcmp{\smo@style}{shortscript}=0
            \titlepagefalse
          \fi
        \fi
      \fi
    \fi
  \fi
  
%process option nologo
\DeclareVoidOption{nologo}{\logofalse}

%load article with the right font-size according to style
\ifscript \PassOptionsToClass{a4paper,12pt}{article} \fi
\ifshortscript \PassOptionsToClass{a4paper,12pt}{article} \fi
\ifexercise \PassOptionsToClass{a4paper,11pt}{article} \fi
\ifexam \PassOptionsToClass{a4paper,11pt}{article}\fi
\ifsolution \PassOptionsToClass{a4paper,11pt}{article}\fi
\LoadClass{article} 

%execute all options 
\ProcessKeyvalOptions*

%first package to load
\RequirePackage[l2tabu]{nag}

%set geometry (for each style)
\ifsolution \RequirePackage [a4paper, left=20mm, right=20mm, top=28.28mm, bottom=28.28mm]{geometry} \fi
\ifexam \RequirePackage [a4paper, left=20mm, right=20mm, top=28.28mm, bottom=28.28mm]{geometry} \fi
\ifscript \RequirePackage[a4paper, left=25.63401mm, right=25.63401mm, top=36.25381mm, bottom=36.25381mm]{geometry} \fi
\ifexercise \RequirePackage[a4paper, left=20mm, right=20mm, top=28.28mm, bottom=28.28mm]{geometry} \fi
\ifshortscript \RequirePackage[a4paper, left=20mm, right=20mm, top=28.28mm, bottom=28.28mm]{geometry} \fi

%load packages
\RequirePackage{parskip}
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\ifgerman \RequirePackage[ngerman]{babel}\fi
\iffrench \RequirePackage[french]{babel}\fi
\ifitalian \RequirePackage[italian]{babel}\fi
\RequirePackage{amsmath, amsthm, amssymb}
\RequirePackage{mathtools}%DeclarePairedDelimiter
\RequirePackage{graphicx}
\RequirePackage[shortlabels]{enumitem}

%parskip and amsthm fix
\begingroup 
\makeatletter
   \@for\theoremstyle:=definition,remark,plain\do{
     \expandafter\g@addto@macro\csname th@\theoremstyle\endcsname{
        \addtolength\thm@preskip\parskip
     }
   }
\endgroup

%if exercise: change section title
\ifexercise
\usepackage[explicit]{titlesec}
%\titleformat{\section}[block] 
%{}{}{8pt}{\Large\bfseries\filcenter\titlerule*[0.3pc]{-}\thesection{ }#1\titlerule*[0.3pc]{-}}
\titleformat{\section}[frame] 
{\vspace{1cm}}{}{8pt}{\Large\bfseries\filcenter\thesection{ }#1}
%\titleformat{\subsection}[frame] 
%{}{}{8pt}{\large\filcenter\thesubsection{ }#1}

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

% if exercise: Define new enumerations
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
\ifgerman \DeclareMathOperator{\ggT}{ggT} \fi
\iffrench \DeclareMathOperator{\ggT}{pgdc} \fi
\ifitalian \DeclareMathOperator{\ggT}{mcd} \fi
\ifgerman \DeclareMathOperator{\kgV}{kgV} \fi
\iffrench \DeclareMathOperator{\kgV}{ppmc} \fi
\ifitalian \DeclareMathOperator{\kgV}{mcm} \fi
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

%make existing commands prettier
\renewcommand{\phi}{\varphi} %non capital phi
\renewcommand{\div}{\, | \,}

%set default author to empty
\let\@author\@empty

%if exam: define variables
\let\@examdate\relax
\def\examdate#1{\def\@examdate{#1}}
\let\@place\relax
\def\place#1{\def\@place{#1}}
\let\@examtime\relax
\def\examtime#1{\def\@examtime{#1}}

%%%%%%%%%%%%%%%% At Begin of Document %%%%%%%%%%%%%%%%%%%%

\AtBeginDocument{

%if titlepage: make more space for table of contents, no page number
\iftitlepage \advance\vsize by 2cm \thispagestyle{empty} \fi
%compensate for logo
\vspace*{-2.5cm}

%insert logo (or placeholder if 'nologo' is given)
\iflogo
\ifgerman \IfFileExists{graphics/de-smo_logo.pdf}{{\includegraphics{graphics/de-smo_logo}}}{\ClassError{smo}{Logo (`de-smo_logo.pdf') is missing! Use option 'nologo' to compile without}{}} \fi
\iffrench \IfFileExists{graphics/fr-smo_logo.pdf}{{\includegraphics{graphics/fr-smo_logo}}}{\ClassError{smo}{Logo (`fr-smo_logo.pdf') is missing! Use option 'nologo' to compile without}{}} \fi
\ifitalian \IfFileExists{graphics/it-smo_logo.pdf}{{\includegraphics{graphics/it-smo_logo}}}{\ClassError{smo}{Logo (`it-smo_logo.pdf') is missing! Use option 'nologo' to compile without}{}} \fi
\else
\leavevmode \vspace{3.13cm} %needs to be updated!
\fi
\vspace{0.5cm}
\iftitlepage \vspace{1cm} \fi

%titlepage design if script
\ifscript
\begin{center}
\Huge{\textbf{\@title}}\\
\if\@author\@empty \else{\vspace{1.5cm} \Large{\@author}\\} \fi
\vspace{0.7cm}
\ifgerman \large{Aktualisiert: \today}\\ \fi
\iffrench \large{Actualisé: \today}\\ \fi
\ifitalian \large{Aggiornato: \today}\\ \fi
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

%titlepage design if exam
\ifexam
\pagestyle{empty}
\begin{center}
\vspace{5mm}
{\Huge{\textbf{ \@title}}} \\
\medskip
\@place\ - \@examdate
\end{center}
\vspace{8mm}
\ifgerman Zeit: \@examtime \\
Jede Aufgabe ist 7 Punkte wert. \fi
\iffrench Temps : \@examtime \\
Chaque exercice vaut 7 points. \fi
\ifitalian Durata : \@examtime \\
Ogni esercizio vale 7 punti. \fi
\vspace{10mm}
\fi

%titlepage design if solution
\ifsolution
\begin{center}
\vspace{5mm}
{\Huge{\textbf{ \@title}}} \\
\medskip
\@place\ - \@examdate
\ifgerman \fi
\iffrench \fi
\ifitalian \fi
\end{center}
\vspace{8mm}
\vspace{10mm}
\fi

%titlepage design if exercise
\ifexercise
\begin{center}
\LARGE{\textbf{\@title}}\\[3mm]
\ifgerman \large{Aktualisiert: \today}\\ \fi
\iffrench \large{Actualisé: \today}\\ \fi
\ifitalian \large{Aggiornato: \today}\\ \fi
\end{center}
\fi

%titlepage design if shortscript
\ifshortscript
\begin{center}
\Huge{\textbf{\@title}}\\[3mm]
\ifgerman \large{Aktualisiert: \today}\\ \fi
\iffrench \large{Actualisé: \today}\\ \fi
\ifitalian \large{Aggiornato: \today}\\ \fi
\vspace{1cm}
\end{center}
\fi
}