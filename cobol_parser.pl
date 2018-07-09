#!/usr/bin/perl -w
use strict;
use POSIX;
use File::Basename;
use Encode 'encode', 'decode';

# TEST_CASE (SAMPLE):
# perl cobol_parser.pl DIRNAME/OCSQ41T.COBOL --show-line

package vars;
my $sdir = ".";
my $target;
my @cbl_path = ();

=cut
my @reserved_words = (
"ACCEPT", "ALPHABETIC-LOWER", "APPLY",
"ACCESS", "ALPHABETIC-UPPER", "ARE",
"ADD", "ALPHANUMERIC", "AREA",
"ADDRESS", "ALPHANUMERIC-EDITED", "AREAS",
"ADVANCING", "ALSO", "ASCENDING",
"AFTER", "ALTER", "ASSIGN",
"ALL", "ALTERNATE", "AT",
"ALPHABET", "AND", "AUTHOR",
"ALPHABETIC", "ANY",
"BASIS", "BINARY", "BOTTOM",
"BEFORE", "BLANK", "BY",
"BEGINNING", "BLOCK",
"CALL", "COLUMN", "COMPUTATIONAL-5",
"CANCEL", "COM-REG", "COMPUTE",
"CBL", "COMMA", "CONFIGURATION",
"CD", "COMMON", "CONTAINS",
"CF", "COMMUNICATION", "CONTENT",
"CH", "COMP", "CONTINUE",
"CHARACTER", "COMP-1", "CONTROL",
"CHARACTERS", "COMP-2", "CONTROLS",
"CLASS", "COMP-3", "CONVERTING",
"CLASS-ID", "COMP-4", "COPY",
"CLOCK-UNITS", "COMP-5", "CORR",
"CLOSE", "COMPUTATIONAL", "CORRESPONDING",
"COBOL", "COMPUTATIONAL-1", "COUNT",
"CODE", "COMPUTATIONAL-2", "CURRENCY",
"CODE-SET", "COMPUTATIONAL-3",
"COLLATING", "COMPUTATIONAL-4",
"DATA", "DEBUG-SUB-1", "DESTINATION",
"DATE-COMPILED", "DEBUG-SUB-2", "DETAIL",
"DATE-WRITTEN", "DEBUG-SUB-3", "DISPLAY",
"DAY", "DEBUGGING", "DISPLAY-1",
"DAY-OF-WEEK", "DECIMAL-POINT", "DIVIDE",
"DBCS", "DECLARATIVES", "DIVISION",
"DE", "DELETE", "DOWN",
"DEBUG-CONTENTS", "DELIMITED", "DUPLICATES",
"DEBUG-ITEM", "DELIMITER", "DYNAMIC",
"DEBUG-LINE", "DEPENDING",
"DEBUG-NAME", "DESCENDING",
"EGCS", "END-INVOKE", "ENDING",
"EGI", "END-MULTIPLY", "ENTER",
"EJECT", "END-OF-PAGE", "ENTRY",
"ELSE", "END-PERFORM", "ENVIRONMENT",
"EMI", "END-READ", "EOP",
"ENABLE", "END-RECEIVE", "EQUAL",
"END", "END-RETURN", "ERROR",
"END-ADD", "END-REWRITE", "ESI",
"END-CALL", "END-SEARCH", "EVALUATE",
"END-COMPUTE", "END-START", "EVERY",
"END-DELETE", "END-STRING", "EXCEPTION",
"END-DIVIDE", "END-SUBTRACT", "EXIT",
"END-EVALUATE", "END-UNSTRING", "EXTEND",
"END-IF", "END-WRITE", "EXTERNAL",
"FALSE", "FILLER", "FOR",
"FD", "FINAL", "FROM",
"FILE", "FIRST", "FUNCTION",
"FILE-CONTROL", "FOOTING",
"GENERATE", "GO", "GROUP",
"GIVING", "GOBACK",
"GLOBAL", "GREATER",
"HEADING", "HIGH-VALUE", "HIGH-VALUES",
"I-O", "INDICATE", "INSPECT",
"I-O-CONTROL", "INHERITS", "INSTALLATION",
"ID", "INITIAL", "INTO",
"IDENTIFICATION", "INITIALIZE", "INVALID",
"IF", "INITIATE", "INVOKE",
"IN", "INPUT", "IS",
"INDEX", "INPUT-OUTPUT",
"INDEXED", "INSERT",
"JUST", "JUSTIFIED",
"KANJI", "KEY",
"LABEL", "LIMIT", "LINES",
"LAST", "LIMITS", "LINKAGE",
"LEADING", "LINAGE", "LOCAL-STORAGE",
"LEFT", "LINAGE-COUNTER", "LOCK",
"LENGTH", "LINE", "LOW-VALUE",
"LESS", "LINE-COUNTER", "LOW-VALUES",
"MEMORY", "METHOD", "MORE-LABELS",
"MERGE", "METHOD-ID", "MOVE",
"MESSAGE", "MODE", "MULTIPLE",
"METACLASS", "MODULES", "MULTIPLY",
"NATIVE", "NO", "NUMBER",
"NATIVE_BINARY", "NOT", "NUMERIC",
"NEGATIVE", "NULL", "NUMERIC-EDITED",
"NEXT", "NULLS",
"OBJECT", "ON", "OTHER",
"OBJECT-COMPUTER", "OPEN", "OUTPUT",
"OCCURS", "OPTIONAL", "OVERFLOW",
"OF", "OR", "OVERRIDE",
"OFF", "ORDER",
"OMITTED", "ORGANIZATION",
"PACKED-DECIMAL", "PIC", "PROCEDURE-POINTER",
"PADDING", "PICTURE", "PROCEDURES",
"PAGE", "PLUS", "PROCEED",
"PAGE-COUNTER", "POINTER", "PROCESSING",
"PASSWORD", "POSITION", "PROGRAM",
"PERFORM", "POSITIVE", "PROGRAM-ID",
"PF", "PRINTING", "PURGE",
"PH", "PROCEDURE",
"QUEUE", "QUOTE", "QUOTES",
"RANDOM", "RELATIVE", "RESERVE",
"RD", "RELEASE", "RESET",
"READ", "RELOAD", "RETURN",
"READY", "REMAINDER", "RETURN-CODE",
"RECEIVE", "REMOVAL", "RETURNING",
"RECORD", "RENAMES", "REVERSED",
"RECORDING", "REPLACE", "REWIND",
"RECORDS", "REPLACING", "REWRITE",
"RECURSIVE", "REPORT", "RF",
"REDEFINES", "REPORTING", "RH",
"REEL", "REPORTS", "RIGHT",
"REFERENCE", "REPOSITORY", "ROUNDED",
"REFERENCES", "RERUN", "RUN",
"SAME", "SIGN", "STANDARD",
"SD", "SIZE", "STANDARD-1",
"SEARCH", "SKIP1", "STANDARD-2",
"SECTION", "SKIP2", "START",
"SECURITY", "SKIP3", "STATUS",
"SEGMENT", "SORT", "STOP",
"SEGMENT-LIMIT", "SORT-CONTROL", "STRING",
"SELECT", "SORT-CORE-SIZE", "SUB-QUEUE-1",
"SELF", "SORT-FILE-SIZE", "SUB-QUEUE-2",
"SEND", "SORT-MERGE", "SUB-QUEUE-3",
"SENTENCE", "SORT-MESSAGE", "SUBTRACT",
"SEPARATE", "SORT-MODE-SIZE", "SUM",
"SEQUENCE", "SORT-RETURN", "SUPER",
"SEQUENTIAL", "SOURCE", "SUPPRESS",
"SERVICE", "SOURCE-COMPUTER", "SYMBOLIC",
"SET", "SPACE", "SYNC",
"SHIFT-IN", "SPACES", "SYNCHRONIZED",
"SHIFT-OUT", "SPECIAL-NAMES",
"TABLE", "TEXT", "TITLE",
"TALLY", "THAN", "TO",
"TALLYING", "THEN", "TOP",
"TAPE", "THROUGH", "TRACE",
"TERMINAL", "THRU", "TRAILING",
"TERMINATE", "TIME", "TRUE",
"TEST", "TIMES", "TYPE",
"UNIT", "UP", "USE",
"UNSTRING", "UPON", "USING",
"UNTIL", "USAGE",
"VALUE", "VALUES", "VARYING",
"WHEN", "WORDS", "WRITE-ONLY",
"WHEN-COMPILED", "WORKING-STORAGE",
"WITH", "WRITE",
"ZERO", "ZEROES", "ZEROS"
);
=cut

my $close_words =
"END-INVOKE|END-MULTIPLY|END-OF-PAGE|END-PERFORM|END-READ|END-RECEIVE|END-RETURN|END-REWRITE|END-ADD|"
  . "END-SEARCH|END-CALL|END-COMPUTE|END-START|END-DELETE|END-STRING|END-DIVIDE|END-SUBTRACT|END-EVALUATE|"
  . "END-UNSTRING|END-IF|END-WRITE";

my $logic_cmds =
"EXEC|END-EXEC|INVOKE|ACQUIRE|ALTER|CANCEL|COMMIT|CONTINUE|DELETE|DIVIDE|DROP|PAGE|ENTER|EXIT|GOBACK|INSPECT|MERGE|OPEN|RELEASE|"
  . "RETURN|ROLLBACK|SEARCH|SET|SORT|CLOSE|MOVE|WRITE|REWRITE|COMPUTE|ADD|DISPLAY|PERFORM|EVALUATE|THEN|"
  . "MULTIPLY|ACCEPT|CALL|INITIALIZE|GO TO|READ|RECEIVE|ELSE|START|STOP|STRING|SUBTRACT|UNSTRING|IF|WHEN|$close_words";

=cut
undef $logic_cmds;
foreach my $item (@reserved_words) {
$logic_cmds .= $item . "|";
}
$logic_cmds =~ s/\|$//;
=cut

my ( $show_line, $strict_mode, $no_cbl, $add_space, $raw_no_remark,
    $with_filename )
  = (0) x 6;

package base;

sub uniq {
    return keys %{ { map { $_ => 1 } @_ } };
}

sub _slurp {
    my $filename = shift;
    open my $in, '<:raw', $filename
      or die "Cannot open '$filename' for slurping";
    local $/;
    my $contents = <$in>;
    close($in);
    return $contents;
}

sub parse {
    my ( $content, $replacing_str ) = @_;
    my $new_content;
    my $cnt = 0;
    foreach my $ls ( split /\n/, $content ) {
        $cnt++;
        my $multiline = 0;
        if ( $ls =~ /^......(\*|\/)/ ) {

            # * and / are considered comments (6th column)
            next;
        }
        elsif ( $ls =~ /^......\-/ ) {

            # multiple lines
            $multiline = 1;
            $ls =~ s/^(......)-( +)'/$1 $2/;
        }
        elsif ( $ls !~ /^...... / ) {

            # invalid syntax: should not happen
            next;
        }
        $ls = substr $ls, 0, 72;
        if ( $ls =~ /^...... (\s*)$/ ) {
            next;
        }
        $ls =~ s/^.......//;
        $ls =~ s/( +)/ /g;
        $ls =~ s/^ //g;
        $ls =~ s/ $//g;
        if ( $show_line eq 1 ) {
            $ls = "[YKPT_" . $cnt . "_TPKY]:" . $ls;
        }
        if ( $multiline eq 1 ) {
            chop $new_content;
        }
        if ( $ls =~ /\.$/ ) {
            $new_content .= $ls . "\n";
        }
        else {
            $new_content .= $ls . " ";
        }
    }
    undef $content;

    # The strict mode
    if ( $strict_mode eq 1 ) {
        if ( $show_line eq 1 ) {
            $new_content =~ s/^\[YKPT_(\d+)_TPKY\]:/$1:/mg;
            $new_content =~ s/\[YKPT_(\d+)_TPKY\]://mg;
        }
        return $new_content;
    }

    # Replaces strings when needed
    if ( $replacing_str =~ /^(\S+):(\S+)$/ ) {
        my $from = $1;
        my $to   = $2;
        if ( $from =~ /^==(.+)==$/ && $to =~ /^==(.+)==$/ ) {
            $from =~ s/^==(\S+)==$/$1/;
            $to =~ s/^==(\S+)==$/$1/;
        }
        $new_content =~ s/\Q$from\E/$to/mg;
    }

    # Splits chunks of copybooks
    foreach my $ls ( split /\n/, $new_content ) {
        if ( $ls =~ /'/ ) {
            $ls =~ s/'/\n'\n/g;
            $content .= $ls . "\n";
            next;
        }
        if ( $ls =~ / COPY (\S+)/ ) {
            my $item = $1;
            $ls =~ s/ COPY \Q$item\E/\nCOPY $item/;
        }
        $ls =~ s/'/\n'\n/g;
        $content .= $ls . "\n";
    }

    $new_content = $content;
    undef $content;
    if ( $show_line eq 1 ) {
        $new_content =~ s/^\[YKPT_(\d+)_TPKY\]:/$1:/mg;
        $new_content =~ s/\[YKPT_(\d+)_TPKY\]://mg;
    }

    # Parses the logic commands
    my $quote_hold = 0;
    foreach my $ls ( split /\n/, $new_content ) {
        if ( $ls =~ /^'$/ ) {
            $content .= "'";
            if ( $quote_hold eq 0 ) {
                $quote_hold = 1;
            }
            else {
                $quote_hold = 0;
            }
            next;
        }
        if ( $quote_hold eq 0 ) {
            $ls =~ s/ \*\>(.+)//;

            while (1) {
                if ( $ls =~ / ($logic_cmds) / ) {
                    my $item = $1;
                    $ls =~ s/ $item /\n$item /;
                }
                else {
                    last;
                }
            }
            while (1) {
                if ( $ls =~ / ($close_words)($|\.$)/ ) {
                    my $item = $1;
                    $ls =~ s/ $item($|\.$)/\n$item$1/;
                }
                else {
                    last;
                }
            }
        }
        $content .= $ls . "\n";
    }
    $content =~ s/\n'/'/mg;
    if ( $show_line eq 1 ) {
        $new_content = $content;
        undef $content;
        my $last_num = 0;
        foreach my $ls ( split /\n/, $new_content ) {
            my $done = 0;
            if ( $ls =~ /^(\d+):/ ) {
                $last_num = $1;
                $done     = 1;
            }
            if ( $done eq 0 ) {
                $ls = "$last_num:" . $ls;
            }
            $content .= $ls . "\n";
        }
    }
    return $content;
}

sub get_copy_content {
    my ( $ls, $tag_enabled, $replacing_str, $ls_cnt ) = @_;
    my $item;
    if ( $show_line eq 1 ) {
        if ( $ls =~ /^(\d+):COPY (\S+)/ ) {
            $ls =~ s/^(\d+)://;
        }
    }
    if ( $ls =~ /^COPY (\S+)/ ) {
        $item = $1;
        $item =~ s/\.$//;
    }
    my $line;
    if ( $show_line eq 1 ) {
        $line = $ls_cnt . ":";
    }
    foreach my $copy_path (@cbl_path) {
        if ( -f "$copy_path/$item.cpy" ) {
            my $str_to_return =
              parse( _slurp("$copy_path/$item.cpy"), $replacing_str );
            if ( $tag_enabled eq 1 ) {
                return
                    "$line*>CBL_START_$item"
                  . "_$replacing_str\n"
                  . $str_to_return
                  . "\n$line*>CBL_END_$item"
                  . "_$replacing_str\n";
            }
            else {
                return
                    "$line*>CBL_IN_CBL_START_$item"
                  . "_$replacing_str\n"
                  . $str_to_return
                  . "\n$line*>CBL_IN_CBL_END_$item"
                  . "_$replacing_str\n";
            }
        }
    }
    if ( $tag_enabled eq 1 ) {
        return
            "$line*>CBL_NOT_FOUND_START_$item"
          . "_$replacing_str\n*$ls\n$line*>CBL_NOT_FOUND_END_$item"
          . "_$replacing_str\n";
    }
    else {
        return
            "$line*>CBL_IN_CBL_NOT_FOUND_START_$item"
          . "_$replacing_str\n*$ls\n$line*>CBL_IN_CBL_NOT_FOUND_END_$item"
          . "_$replacing_str\n";
    }
}

sub extract_copy {
    my $content = $_[0];
    my $opt     = $_[1];
    my $new_content;
    my $ls_cnt = 0;
    foreach my $ls ( split /\n/, $content ) {
        $ls_cnt++;
        $ls =~ s/^ //g;
        $ls =~ s/ $//g;
        if ( $show_line eq 1 ) {
            if ( $ls =~ /^(\d+):COPY (\S+)/ ) {
                if ( ( split /\n/, $content )[ $ls_cnt - 1 ] =~
                    /(REPLACING|REPLACING LEADING) (\S+) BY (\S+)\./ )
                {
                    my $replacing_str = $1 . ":" . $2;
                    $new_content .=
                      get_copy_content( $ls, $opt, $replacing_str, $ls_cnt )
                      . "\n";
                }
                else {
                    $new_content .=
                      get_copy_content( $ls, $opt, 0, $ls_cnt ) . "\n";
                }
            }
            else {
                $new_content .= $ls . "\n";
            }
        }
        elsif ( $ls =~ /^COPY (\S+)/ ) {
            if ( ( split /\n/, $content )[ $ls_cnt - 1 ] =~
                /(REPLACING|REPLACING LEADING) (\S+) BY (\S+)\./ )
            {
                my $replacing_str = $1 . ":" . $2;
                $new_content .=
                  get_copy_content( $ls, $opt, $replacing_str, $ls_cnt ) . "\n";
            }
            else {
                $new_content .=
                  get_copy_content( $ls, $opt, 0, $ls_cnt ) . "\n";
            }
        }
        else {
            $new_content .= $ls . "\n";
        }
    }
    return $new_content;
}

sub proc {
    unless ( -f $sdir . "/" . $target ) {
        $sdir = ".";
        unless ( -f $sdir . "/" . $target ) {
            $sdir = "";
            unless ( -f $sdir . "/" . $target ) {
                print "STOPPED: FILE NOT FOUND: $sdir/$target\n";
                exit();
            }
        }
    }

    my $content;
    if ( $target =~ /\.cpy$/ ) {
        print "STOPPED: .cpy filename extension is not supported. ($target)\n";
        exit();
    }
    else {
        $content = _slurp("$sdir/$target");

    # Four divisions
    # (DATA DIVISION normally includes FILE SECTION and WORKING-STORAGE SECTION)
    # "IDENTIFICATION( +)DIVISION",
    # "ENVIRONMENT( +)DIVISION",
    # "DATA( +)DIVISION",
    # "PROCEDURE( +)DIVISION"

        #if ($content !~ /^......[^(\*|\/)](.*)IDENTIFICATION( +)DIVISION/m) {
## IDENTIFICATION is required
        #print STDERR "NOT A PROPER COBOL FILE ($target)\n";
        #exit();
        #}
    }

    if ( $raw_no_remark eq 1 ) {
        $content =~ s/^......(\*|\/)(.+)$//mg;
        $content =~ s/^....../      /mg;
        $content =~ s/^\s*\n//mg;    # remove empty lines
        print "      *>PATH: $target\n";
        print $content;
        exit();
    }

    if ( $no_cbl eq 0 ) {

        # Parses the contents first with copybook extracted
        $content = extract_copy( parse( $content, 0 ), 1 );

        # Parses CBL inside CBL
        while (1) {
            if ( $show_line eq 1 ) {
                if ( $content =~ /^(\d+):COPY (\S+)/m ) {

                    #$content = extract_copy(parse($content, 0), 0);
                    $content = extract_copy( $content, 0 );
                }
                else {
                    last;
                }
            }
            else {
                if ( $content =~ /^COPY (\S+)/m ) {

                    #$content = extract_copy(parse($content, 0), 0);
                    $content = extract_copy( $content, 0 );
                }
                else {
                    last;
                }
            }
        }
    }
    else {
        $content = parse( $content, 0 );
        $content =~ s/^( )+//mg;
    }
    $content =~ s/^\s*\n//mg;
    $content =~ s/ \.$/\./mg;
    $content = "*>PATH: $target\n" . $content;
    if ($add_space) {
        if ( $show_line eq 1 ) {
            my $new_content = $content;
            undef $content;
            foreach my $ls ( split /\n/, $new_content ) {
                if ( $ls =~ /^(\d+):(.+)$/ ) {
                    my $num   = $1;
                    my $after = $2;
                    my $to_add;
                    if ( $after !~ /^(\*|\/)/ ) {
                        $to_add = " ";
                    }
                    $content .=
                        " " x ( 6 - length($num) )
                      . $num
                      . $to_add
                      . $after . "\n";
                    next;
                }
                if ( $ls =~ /^(\*|\/)/ ) {
                    $content .= "      " . $ls . "\n";
                    next;
                }
                $ls =~ s/^/       /g;
                $content .= $ls . "\n";
                next;
            }
        }
        else {
            $content =~ s/^/       /mg;
            $content =~ s/^       (\*|\/)/      \*/mg;
        }
    }
    if ($with_filename) {
        $content =~ s/^/$target:/mg;
    }
    print $content;
    exit();
}

package main;
main();

sub main {
    foreach my $item (@ARGV) {
        if ( $item =~ /^--show-line$/ ) {
            $show_line = 1;
            next;
        }
        elsif ( $item =~ /^--strict$/ ) {
            $strict_mode = 1;
            next;
        }
        elsif ( $item =~ /^--no-copybook$/ ) {
            $no_cbl = 1;
            next;
        }
        elsif ( $item =~ /^--space$/ ) {
            $add_space = 1;
            next;
        }
        elsif ( $item =~ /^--raw-without-remark$/ ) {
            $raw_no_remark = 1;
            next;
        }
        elsif ( $item =~ /^--with-filename$/ ) {
            $with_filename = 1;
            next;
        }
        elsif ( $item =~ /^--c:(.+)$/ ) {
            my $path = $1;
            if ( $path =~ /:/ ) {
                foreach my $path_splitted ( split /:/, $path ) {
                    if ( -d $path_splitted ) {
                        push @cbl_path, $path_splitted;
                    }
                }
            }
            else {
                if ( -d $path ) {
                    push @cbl_path, $1;
                }
            }
            next;
        }
        elsif ( $item =~ /^--help$/ ) {
            undef $target;
            last;
        }
        $target = $item;
    }
    unless ($target) {
        print "\n USAGE: "
          . ::basename($0)
          . " [filename] [--show-line] [--strict] [--no-copybook]\n"
          . "        [--space] [--raw-without-remark] [--with-filename] [--c:(path)]\n\n"
          . "            [--show-line] : Displays line number.\n"
          . "               [--strict] : Enables strict mode.\n"
          . "          [--no-copybook] : Does not extract the copybook for parsing.\n"
          . "                [--space] : Appends spaces to the left.\n"
          . "   [--raw-without-remark] : Removes only remarks.\n"
          . "        [--with-filename] : Shows with the filename\n"
          . "             [--c:(path)] : Appends the copybook path.\n\n";
        exit();
    }
    base::proc();
}

__END__

