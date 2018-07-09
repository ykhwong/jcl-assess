#!/usr/bin/perl -w
use strict;
use POSIX;
use File::Basename;
use File::Copy;

# GLOBAL VARS
my $dir_conf;
my $depth       = 3;
my $do_not_copy = 0;
my $crop_len    = 72;
my ( $PATH, $BIND, $COPY, $INCLUDE, $JCL, $PARM, $PROC, $COBOL, $CICS, $BMS );
my $input_list;
my $note_list;
my $cics_list;
my $bms_list;
my $jcl_file_list;
my $bms_file_list;
my $cics_file_list;
my $calltree_pgm_list;
my $calltree_parm_list;
my $calltree_proc_list;
my $calltree_missing_proc_list;
my $calltree_missing_pgm_list;
my $calltree_missing_copy_list;
my $calltree_missing_include_list;
my $calltree_missing_parm_list;

my $calltree_copy_list;
my $calltree_include_list;

#my $calltree_call_list;

my $missing_jcl_list;
my $missing_bms_list;
my $missing_cics_list;
my @UTIL;
my ( $INPUT_DEFAULT, $INPUT_IKJEFT01 );

# DIRNAME
my $config_dir = "./config";
my $result_dir = "./result";

# INPUT
my $dir_lst   = $config_dir . "/" . "dir.lst";
my $jcl_lst   = $config_dir . "/" . "jcl.lst";
my $util_lst  = $config_dir . "/" . "util.lst";
my $input_lst = $config_dir . "/" . "input.lst";
my $cics_lst  = $config_dir . "/" . "cics.lst";
my $bms_lst   = $config_dir . "/" . "bms.lst";

# OUTPUT
my $calltree_pgm_lst          = $result_dir . "/" . "calltree_pgm.lst";
my $calltree_proc_lst         = $result_dir . "/" . "calltree_proc.lst";
my $calltree_missing_proc_lst = $result_dir . "/" . "calltree_missing_proc.lst";
my $calltree_missing_pgm_lst  = $result_dir . "/" . "calltree_missing_pgm.lst";
my $calltree_missing_copy_lst = $result_dir . "/" . "calltree_missing_copy.lst";
my $calltree_missing_include_lst =
$result_dir . "/" . "calltree_missing_include.lst";
my $calltree_missing_parm_lst = $result_dir . "/" . "calltree_missing_parm.lst";
my $missing_jcl_lst           = $result_dir . "/" . "missing_jcl.lst";
my $missing_bms_lst           = $result_dir . "/" . "missing_bms.lst";
my $missing_cics_lst          = $result_dir . "/" . "missing_cics.lst";

my $calltree_copy_lst    = $result_dir . "/" . "calltree_copy.lst";
my $calltree_include_lst = $result_dir . "/" . "calltree_include.lst";
my $calltree_parm_lst    = $result_dir . "/" . "calltree_parm.lst";

my $note_lst = $result_dir . "/" . "note.lst";

package file;

sub cp_file {
	my ( $from, $to ) = @_;
	if ( $do_not_copy eq 0 ) {
		unless ( -f $to ) {
			::copy( $from, $to ) or die(0);
		}
	}
}

sub load_file {
	my $filename = shift;
	unless ( -f $filename ) {
		print STDERR "File not found: $filename\n";
		exit 1;
	}
	open my $in, '<:raw', $filename or die("Check the file: $filename\n");
	local $/;
	my $contents = <$in>;
	close($in);
	return $contents;
}

sub save_file {
	my ( $list, $lst, $is_format ) = @_;
	if ( $is_format eq 1 ) {
		$list = base::report_format($list);
	}
	open my $fd, ">>", $lst or die(0);
	print $fd $list;
	close $fd;
}

package base;

sub uniq_helper {
	my %seen;
	grep !$seen{$_}++, @_;
}

sub uniq {
	my ($orig_str) = @_;
	my $result_str;
	my @var;
	foreach my $ls ( split /\n/, $orig_str ) { push @var, $ls; }
	@var = uniq_helper(@var);
	foreach my $ls (@var) { $result_str .= $ls . "\n"; }
	return $result_str;
}

sub report_format {
	my ($content) = @_;
	my $result_content;
	foreach my $ls ( split /\n/, $content ) {
		my $line = ( split / : /, $ls )[1];
		my $to_line = ::basename($line);
		$ls =~ s/\Q$line\E/$to_line/;
		$result_content .= $ls . "\n";
	}
	return $result_content;
}

sub FixLen {
	my $str = $_[0];
	chomp $str;
	return $str . " " x ( $crop_len - length($str) );
}

sub cobol_search {
	my ( $file_list, $dirname, $path_skip ) = @_;
	my $type = ::toupper($dirname);
	foreach my $ls ( split /\n/, $file_list ) {
		my $ignore = 0;
		foreach my $util (@UTIL) {
			if ( $ls eq $util ) { $ignore = 1; last; }
		}
		if ( $ignore eq 1 ) { next; }

		#print "ANALYZE: ./$dirname/$ls\n";
		my $contents;
		if ( $path_skip eq 1 ) {
			$contents = file::load_file("$ls");
		}
		else {
			$contents = file::load_file("./$dirname/$ls");
		}
		my $cnt = 0;
		my $tmp_contents;
		foreach my $ls2 ( split /\n/, $contents ) {
			if ( $ls2 =~ /^......\*/ ) { next; }
			$ls2 = FixLen( substr( $ls2, 0, $crop_len ) );
			if ( $ls2 =~ /^\s*$/ ) { next; }
			$tmp_contents .= $ls2 . "\n";
		}
		$contents = $tmp_contents;
		foreach my $ls2 ( split /\n/, $contents ) {
			$cnt++;
			if ( $ls2 =~ / DISPLAY +\Q'\E/ ) { next; }
			if ( $ls2 =~ / COPY / ) {
				my $copy;
				if ( $ls2 =~ / COPY +(\S+)/ ) {
					my $COPY_t;
					$copy = $1;
					$copy =~ s/\.$//;
					if ( $COPY =~ /:/ ) {
						$COPY_t = $COPY;
					}
					else {
						$COPY_t = $COPY . ":";
					}
					my $copy_found = 0;
					if ( $copy =~ /^DFHAID|DFHBMSCA$/ ) {
						$calltree_copy_list .=
						"$type : " . $ls . " : " . $copy . "\n";
						$copy_found = 1;
					}
					else {
						foreach my $COPY_s ( split /:/, $COPY_t ) {
							if (   -f "$PATH/$COPY_s/$copy"
								|| -f "$PATH/$COPY_s/$copy.cpy" )
							{
								$calltree_copy_list .=
								"$type : " . $ls . " : " . $copy . "\n";
								if ( -f "$PATH/$COPY_s/$copy" ) {
									file::cp_file(
										"$PATH/$COPY_s/$copy",
										"./copy/$copy.cpy"
									);
									$copy_found = 1;
									last;
								}
								elsif ( -f "$PATH/$COPY_s/$copy.cpy" ) {
									file::cp_file( "$PATH/$COPY_s/$copy.cpy",
										"./copy/$copy.cpy" );
									$copy_found = 1;
									last;
								}
							}
						}
					}
					if ( $copy_found eq 0 ) {
						$calltree_missing_copy_list .=
						"$type : " . $ls . " : " . $copy . "\n";
					}
				}
			}
			if ( $ls2 =~ / EXEC +SQL / ) {
				my $include;
				my $exec_sql_include = 0;
				if ( $ls2 =~ / EXEC +SQL +INCLUDE +(\S+) / ) {
					$include          = $1;
					$exec_sql_include = 1;
				}
				elsif ( $ls2 =~ / EXEC +SQL +$/ ) {
					my $line = ( ( split /\n/, $contents )[ $cnt - 1 + 1 ] );
					if ( $line =~ /^....... +INCLUDE +(\S+)/ ) {
						$include          = $1;
						$exec_sql_include = 1;
					}
				}
				if ( $exec_sql_include eq 1 ) {
					my $include_found = 0;
					my $INCLUDE_t;
					if ( $INCLUDE =~ /:/ ) {
						$INCLUDE_t = $INCLUDE;
					}
					else {
						$INCLUDE_t = $INCLUDE . ":";
					}
					foreach my $INCLUDE_s ( split /:/, $INCLUDE_t ) {
						if ( -f "$PATH/$INCLUDE/$include" ) {
							$calltree_include_list .=
							"$type : " . $ls . " : " . $include . "\n";
							file::cp_file(
								"$PATH/$INCLUDE/$include",
								"./include/$include"
							);
							$include_found = 1;
							last;
						}
					}
					if ( $include_found eq 0 ) {
						$calltree_missing_include_list .=
						"$type : " . $ls . " : " . $include . "\n";
					}
				}
			}
			if ( $ls2 =~ / CALL / ) {
				my $pgm;
				if ( $ls2 =~ / CALL +(\S+)/ ) {
					$pgm = $1;
				}
				else {
					my $line = ( ( split /\n/, $contents )[ $cnt - 1 + 1 ] );
					if ( $line =~ /^....... +(\S+)/ ) {
						$pgm = $1;
					}
					else {
						print "Exception! Stopped\n";
						die(0);
					}
				}
				$pgm =~ s/^'//;
				$pgm =~ s/'$//;
				$pgm =~ s/\.$//;
				if ( -f "$PATH/$COBOL/$pgm" ) {
					$calltree_pgm_list .=
					"$type : " . $ls . " : CALL_FROM_PGM : " . $pgm . "\n";
					file::cp_file( "$PATH/$COBOL/$pgm", "./cobol/$pgm" );
					cobol_search( "$PATH/$COBOL/$pgm", "cobol", 1 );
				}
				else {
					my $util_ignore = 0;
					foreach my $util (@UTIL) {
						if ( $util eq $pgm ) {
							$util_ignore = 1;
							last;
						}
					}
					if ( $util_ignore eq 0 ) {
						$calltree_missing_pgm_list .=
							"$type : "
						. $ls
						. " : CALL_FROM_PGM : "
						. $pgm . "\n";
					}
				}
			}
		}
	}
}

sub jcl_proc_search {
	my ( $file_list, $dirname ) = @_;
	my $type = ::toupper($dirname);

	foreach my $ls ( split /\n/, $file_list ) {
		my $miss_ignore = 0;
		foreach my $miss ( split /\n/, $missing_jcl_list ) {
			$miss = ::basename($miss);
			if ( $ls eq $miss ) {
				$miss_ignore = 1;
				last;
			}
		}
		if ( $miss_ignore eq 1 ) { next; }

		#print "ANALYZE: ./$dirname/$ls\n";

		my $contents = file::load_file("./$dirname/$ls");
		my $tmp_contents;
		foreach my $ls2 ( split /\n/, $contents ) {
			if ( $ls2 =~ /^\/\/\*/ ) { next; }
			$tmp_contents .= $ls2 . "\n";
		}
		$contents = $tmp_contents;

		my $cnt = 0;
		foreach my $ls2 ( split /\n/, $contents ) {
			$cnt++;
			if ( $ls2 =~ / (JCLLIB +ORDER=|INCLUDE +MEMBER=)/ ) {
				my $tmp = $ls2;
				$tmp =~ s/\s*$//;
				$note_list .= "$dirname/$ls:$tmp\n";
			}
			if ( $ls2 =~ / RUN +PROGRAM\s*\((\S+)\s*\)/ ) {
				my $cob = $1;
				if ( -f "$PATH/$COBOL/$cob" ) {
					$calltree_pgm_list .=
						"$type : "
					. $ls
					. " : CALL_FROM_RUN_PROGRAM : "
					. $cob . "\n";
					file::cp_file( "$PATH/$COBOL/$cob", "./cobol/$cob" );
				}
				else {
					$calltree_missing_pgm_list .=
						"$type : "
					. $ls
					. " : CALL_FROM_RUN_PROGRAM : "
					. $cob . "\n";
				}
			}
			if ( $ls2 =~ /^\/\/($INPUT_DEFAULT) +DD +(DSN|DSNAME)=(\S+)/ ) {
				my $tmp_dsn = $3;
				my @dsn_grp;
				push @dsn_grp, $tmp_dsn;
				foreach my $num ( 1 ... 10 ) {
					if ( ( split /\n/, $contents )[ $cnt - 1 + $num ] =~
						/^\/\/ +DD +(DSN|DSNAME)=(\S+)/ )
					{
						my $dsn = $2;
						push @dsn_grp, $dsn;
					}
					else {
						last;
					}
				}
				foreach my $dsn (@dsn_grp) {
					my $parmlib;
					my $temp_lib   = 0;
					my $keep_going = 1;
					if ( $dsn =~ /,/ ) {
						$dsn = ( split /\,/, $dsn )[0];
					}
					if ( $dsn =~ /\(/ ) {
						$parmlib = ( split /\(/, $dsn )[0];
						if ( $parmlib =~ /^&/ ) {
							$temp_lib = 1;
						}
						if ( $dsn =~ /\((\S+)\)/ ) {
							$dsn = $1;
						}
						else {
							print "Exception! Stopped\n";
							die(0);
						}
					}
					else {
						$keep_going = 0;

						#print "Exception! Stopped\n"; die(0);
					}
					if ( $dsn =~ /^(\+|-)/ || $dsn =~ /^0$/ ) {
						next;
					}

					if ( $keep_going eq 1 ) {
						my $PARMDIR;
						my $PARM_t;
						if ( $PARM =~ /:/ ) {
							$PARM_t = $PARM;
						}
						else {
							$PARM_t = $PARM . ":";
						}
						my $parm_found = 0;
						foreach my $PARM_s ( split /:/, $PARM_t ) {
							if ( $temp_lib eq 1 ) {
								$PARMDIR = "$PATH/$PARM_s";
							}
							elsif ( -f "$PATH/$parmlib/$dsn" ) {
								$PARMDIR = "$PATH/$parmlib";
							}
							else {
								$PARMDIR = "$PATH/$PARM_s";
							}
							if ( -f "$PARMDIR/$dsn" ) {
								$calltree_parm_list .=
									"$type : "
								. $ls . " : "
								. $parmlib
								. " : $dsn\n";
								file::cp_file( "$PARMDIR/$dsn", "./parm/$dsn" );
								$parm_found = 1;
								last;
							}
						}
						if ( $parm_found eq 0 ) {
							$calltree_missing_parm_list .=
							"$type : " . $ls . " : " . $parmlib . " : $dsn\n";
						}
					}
				}
			}
			if ( $ls2 =~ /^\/\/($INPUT_IKJEFT01) +DD +(DSN|DSNAME)=(\S+)/ ) {
				my $dsn = $3;    # proc
				my $parmlib;
				my $temp_lib   = 0;
				my $keep_going = 1;
				if ( $dsn =~ /,/ ) {
					$dsn = ( split /\,/, $dsn )[0];
				}
				if ( $dsn =~ /\(/ ) {
					$parmlib = ( split /\(/, $dsn )[0];
					if ( $parmlib =~ /^&/ ) {
						$temp_lib = 1;
					}
					if ( $dsn =~ /\((\S+)\)/ ) {
						$dsn = $1;
					}
					else {
						print "Exception! Stopped\n";
						die(0);
					}
				}
				else {
					$keep_going = 0;

					#print "Exception! Stopped\n"; die(0);
				}
				if ( $dsn =~ /^(\+|-)/ || $dsn =~ /^0$/ ) {
					next;
				}
				if ( $keep_going eq 1 ) {
					my $PARMDIR;
					my $PARM_t;
					if ( $PARM =~ /:/ ) {
						$PARM_t = $PARM;
					}
					else {
						$PARM_t = $PARM . ":";
					}
					my $parm_found = 0;
					foreach my $PARM_s ( split /:/, $PARM_t ) {
						if ( $temp_lib eq 1 ) {
							$PARMDIR = "$PATH/$PARM_s";
						}
						elsif ( -f "$PATH/$parmlib/$dsn" ) {
							$PARMDIR = "$PATH/$parmlib";
						}
						else {
							$PARMDIR = "$PATH/$PARM_s";
						}
						if ( -f "$PARMDIR/$dsn" ) {
							$calltree_parm_list .=
							"$type : " . $ls . " : " . $parmlib . " : $dsn\n";
							file::cp_file( "$PARMDIR/$dsn", "./parm/$dsn" );
							$parm_found = 1;
							my $parm_content = file::load_file("$PARMDIR/$dsn");
							my $cob_found    = 0;
							my $cob;
							foreach my $parm_ls ( split /\n/, $parm_content ) {
								if ( $parm_ls =~ /^\/\/\*/ ) { next; }
								if ( $parm_ls =~ / RUN +PROGRAM\((\S+)\)/ ) {
									$cob = $1;
									if ( -f "$PATH/$COBOL/$cob" ) {
										$calltree_pgm_list .=
											"$type : "
										. $ls
										. " : CALL_FROM_RUN_PROGRAM : "
										. $cob . "\n";
										file::cp_file(
											"$PATH/$COBOL/$cob",
											"./cobol/$cob"
										);
										cobol_search( "$PATH/$COBOL/$cob",
											"cobol", 1 );
										$cob_found = 1;
									}
									last;
								}
							}
							if ( $cob && $cob_found eq 0 ) {
								$calltree_missing_pgm_list .=
									"$type : "
								. $ls
								. " : CALL_FROM_RUN_PROGRAM : "
								. $cob . "\n";
							}
						}
					}
					if ( $parm_found eq 0 ) {
						$calltree_missing_parm_list .=
						"$type : " . $ls . " : " . $parmlib . " : $dsn\n";
					}
				}
			}
			if ( $ls2 =~ / EXEC +(\S+)/ ) {
				my $proc = $1;
				$proc =~ s/,(\S*)//;
				if ( $proc =~ /PGM=(\S+)/ ) {
					my $pgm    = $1;
					my $ignore = 0;
					foreach my $util (@UTIL) {
						if ( $pgm eq $util ) { $ignore = 1; last; }
					}
					if ( !-f "$PATH/$COBOL/$pgm" ) {
						if ( $ignore eq 1 ) {
							$calltree_pgm_list .=
								"$type : "
							. $ls
							. " : EXEC_PGM(SUPPORTED_UTIL) : "
							. $pgm . "\n";
							next;
						}
						$calltree_missing_pgm_list .=
						"$type : " . $ls . " : EXEC_PGM : " . $pgm . "\n";
					}
					else {
						$calltree_pgm_list .=
						"$type : " . $ls . " : EXEC_PGM : " . $pgm . "\n";
						file::cp_file( "$PATH/$COBOL/$pgm", "./cobol/$pgm" );
					}
				}
				else {
					my $PROC_t;
					if ( $PROC =~ /:/ ) {
						$PROC_t = $PROC;
					}
					else {
						$PROC_t = $PROC . ":";
					}
					my $found = 0;
					my $tmp_dir;
					foreach my $proc_s ( split /:/, $PROC_t ) {
						if ( -f "$PATH/$proc_s/$proc" ) {
							$found   = 1;
							$tmp_dir = $proc_s;
							last;
						}
					}
					if ( $found eq 0 ) {
						$calltree_missing_proc_list .=
						"$type : " . $ls . " : " . $proc . "\n";
					}
					else {
						$calltree_proc_list .=
						"$type : " . $ls . " : " . $proc . "\n";
						file::cp_file( "$PATH/$tmp_dir/$proc", "./proc/$proc" );
					}
				}
			}
		}
	}

}

sub process {
	print "JCL-ASSESSMENT TOOL v0.1\n\n";

	my $OPT = $ARGV[0];
	if ($OPT) {
		if ( $OPT =~ /(-|--)(help|h)/ ) {
			print "USAGE: $0 [--depth=NUM] [--do-not-copy]\n\n";
			print "    --depth=NUM : Specify the depth of assessment. (default: 3)\n";
			print "  --do-not-copy : Do not copy the files to the repository.\n";
			print "\n";
			exit;
		}
		elsif ( $OPT =~ /(-|--)depth=(\d+)/ ) {
			$depth = $2;
			if ( $depth eq 0 ) {
				print "Warning: depth must be larger than 1. Setting to 3...\n";
				$depth = 3;
			}
			else {
				$depth = $1;
			}
		}
		elsif ( $OPT =~ /(-|--)do-not-copy/ ) {
			print "NOTE: Files will not be copied.\n";
			$do_not_copy = 1;
		}
		else {
			print "Unsupported or invalid parameter: $OPT\n";
			print "Use --help paramter for usage.\n\n";
			exit 1;
		}

	}

	# ENVIRONMENT LOAD
	$dir_conf = file::load_file($dir_lst);
	foreach my $ls ( split /\n/, $dir_conf ) {
		if ( $ls =~ /^\s*#/ || $ls =~ /^\s*$/ ) {
			next;
		}
		if ( $ls =~ /^\s*PATH\s*=\s*(\S+)/ ) {
			my $tmp = $1;
			if ( $PATH || $tmp =~ /:/ ) {
				print STDERR "Duplicate variable: PATH\n";
				exit 1;
			}
			$PATH = $tmp;
			next;
		}
		if ( $ls =~ /^\s*BIND\s*=\s*(\S+)/ ) {
			my $tmp = $1;
			if ( $BIND || $tmp =~ /:/ ) {
				print STDERR "Duplicate variable: BIND\n";
				exit 1;
			}
			$BIND = $tmp;
			next;
		}
		if ( $ls =~ /^\s*COPY\s*=\s*(\S+)/ ) {
			my $tmp = $1;
			if ( not defined $COPY ) {
				$COPY = $tmp;
			}
			else {
				$COPY = "$COPY:$tmp";
			}
			next;
		}
		if ( $ls =~ /^\s*INCLUDE\s*=\s*(\S+)/ ) {
			my $tmp = $1;
			if ( not defined $INCLUDE ) {
				$INCLUDE = $tmp;
			}
			else {
				$INCLUDE = "$INCLUDE:$tmp";
			}
			next;
		}
		if ( $ls =~ /^\s*JCL\s*=\s*(\S+)/ ) {
			my $tmp = $1;
			if ( $JCL || $tmp =~ /:/ ) {
				print STDERR "Duplicate variable: JCL\n";
				exit 1;
			}
			$JCL = $tmp;
			next;
		}
		if ( $ls =~ /^\s*PARM\s*=\s*(\S+)/ ) {
			my $tmp = $1;
			if ( not defined $PARM ) {
				$PARM = $tmp;
			}
			else {
				$PARM = "$PARM:$tmp";
			}
			next;
		}
		if ( $ls =~ /^\s*PROC\s*=\s*(\S+)/ ) {
			my $tmp = $1;
			if ( not defined $PROC ) {
				$PROC = $tmp;
			}
			else {
				$PROC = "$PROC:$tmp";
			}
			next;
		}
		if ( $ls =~ /^\s*COBOL\s*=\s*(\S+)/ ) {
			my $tmp = $1;
			if ( $COBOL || $tmp =~ /:/ ) {
				print "Duplicate variable: COBOL\n";
				exit 1;
			}
			$COBOL = $tmp;
			next;
		}
		if ( $ls =~ /^\s*CICS\s*=\s*(\S+)/ ) {
			my $tmp = $1;
			if ( $CICS || $tmp =~ /:/ ) {
				print "Duplicate variable: CICS\n";
				exit 1;
			}
			$CICS = $tmp;
			next;
		}
		if ( $ls =~ /^\s*BMS\s*=\s*(\S+)/ ) {
			my $tmp = $1;
			if ( $BMS || $tmp =~ /:/ ) {
				print "Duplicate variable: BMS\n";
				exit 1;
			}
			$BMS = $tmp;
			next;
		}
	}
	if ( !defined $PATH ) {
		print STDERR "PATH not found in $dir_lst\n";
		exit 1;
	}
	if ( !defined $BIND ) {
		print STDERR "BIND not found in $dir_lst\n";
		exit 1;
	}
	if ( !defined $COPY ) {
		print STDERR "COPY not found in $dir_lst\n";
		exit 1;
	}
	if ( !defined $INCLUDE ) {
		print STDERR "INCLUDE not found in $dir_lst\n";
		exit 1;
	}
	if ( !defined $JCL ) { print STDERR "JCL not found in $dir_lst\n"; exit 1; }
	if ( !defined $PARM ) {
		print STDERR "PARM not found in $dir_lst\n";
		exit 1;
	}
	if ( !defined $PROC ) {
		print STDERR "PROC not found in $dir_lst\n";
		exit 1;
	}
	if ( !defined $COBOL ) {
		print STDERR "COBOL not found in $dir_lst\n";
		exit 1;
	}
	if ( !defined $CICS ) { print "Warning: CICS is not set in $dir_lst\n"; }
	if ( !defined $BMS )  { print "Warning: BMS is not set in $dir_lst\n"; }

	print "-" x 70 . "\n";
	print "PATH=$PATH\n";
	print "BIND=$BIND\n";
	print "COPY=$COPY\n";
	print "INCLUDE=$INCLUDE\n";
	print "JCL=$JCL\n";
	print "PARM=$PARM\n";
	print "PROC=$PROC\n";
	print "COBOL=$COBOL\n";
	print "CICS=$CICS\n";
	print "BMS=$BMS\n";
	print "-" x 70 . "\n";
	print "\n";

	# IMPORT UTIL LIST
	my $util_list = file::load_file($util_lst);
	foreach my $ls ( split /\n/, $util_list ) {
		unless ( $ls =~ /^\s*$/ ) { push @UTIL, $ls; }
	}

	# IMPORT INPUT LIST
	$input_list = file::load_file($input_lst);
	foreach my $ls ( split /\n/, $input_list ) {
		if ( $ls =~ /^\s*$/ ) { next; }
		if ( $ls =~ /^DEFAULT=(\S+)/ ) {
			my $item = $1;
			$INPUT_DEFAULT = $item;
		}
		if ( $ls =~ /^IKJEFT01=(\S+)/ ) {
			my $item = $1;
			$INPUT_IKJEFT01 = $item;
		}
	}

	# BMS, CICS FILE COPY
	if ($BMS) {
		print "[BMS COPY] START\n";
		$bms_file_list = file::load_file($bms_lst);
		foreach my $ls ( split /\n/, $bms_file_list ) {
			if ( !-f "$PATH/$BMS/$ls" ) {
				$missing_bms_list .= "$PATH/$BMS/$ls\n";
			}
			else {
				file::cp_file( "$PATH/$BMS/$ls", "./bms/$ls" );
			}
		}
		file::save_file( uniq($missing_bms_list), $missing_bms_lst, 0 );
		print "[BMS COPY] COMPLETED\n\n";
	}

	if ($CICS) {
		print "[CICS COPY] START\n";
		$cics_file_list = file::load_file($cics_lst);
		foreach my $ls ( split /\n/, $cics_file_list ) {
			if ( !-f "$PATH/$CICS/$ls" ) {
				$missing_cics_list .= "$PATH/$CICS/$ls\n";
			}
			else {
				file::cp_file( "$PATH/$CICS/$ls", "./cics/$ls" );
				base::cobol_search( "$ls", "cics", 0 );
			}
		}
		file::save_file( uniq($missing_cics_list), $missing_cics_lst, 0 );
		print "[CICS COPY] COMPLETED\n\n";
	}

	# JCL FILE COPY
	print "[JCL COPY] START\n";
	$jcl_file_list = file::load_file($jcl_lst);
	foreach my $ls ( split /\n/, $jcl_file_list ) {
		if ( !-f "$PATH/$JCL/$ls" ) {
			$missing_jcl_list .= "$PATH/$JCL/$ls\n";
		}
		else {
			#print "COPY: $PATH/$JCL/$ls TO ./jcl/$ls\n";
			file::cp_file( "$PATH/$JCL/$ls", "./jcl/$ls" );
		}
	}

	file::save_file( uniq($missing_jcl_list), $missing_jcl_lst, 0 );
	print "[JCL COPY] COMPLETED\n\n";

	print "[JCL/PROC INITIAL ANALYSIS] START\n";
	base::jcl_proc_search( uniq($jcl_file_list), "jcl" );
	print "[JCL/PROC INITIAL ANALYSIS] COMPLETED\n\n";

	# PROC with DEPTH
	print "[JCL/PROC DEEP ANALYSIS] START (DEPTH CNT: $depth)\n";
	my $new_calltree_proc_list = uniq($calltree_proc_list);
	foreach ( 1 .. $depth ) {
		$new_calltree_proc_list = uniq($calltree_proc_list);
		$new_calltree_proc_list =~ s/(.+): //g;
		base::jcl_proc_search( uniq($new_calltree_proc_list), "proc" );
	}

	print "[JCL/PROC DEEP ANALYSIS] COMPLETED\n\n";

	file::save_file( uniq($calltree_missing_proc_list),
		$calltree_missing_proc_lst, 1 );
	file::save_file( uniq($calltree_proc_list), $calltree_proc_lst, 1 );

	print "[COBOL INITIAL ANALYSIS] START\n";

	# By using the calltree_pgm_list, programs should be sorted.
	# COBOL, COPY, INCLUDE
	my $new_calltree_pgm_list = uniq($calltree_pgm_list);
	$new_calltree_pgm_list =~ s/(.+): //g;
	base::cobol_search( uniq($new_calltree_pgm_list), "cobol", 0 );
	print "[COBOL INITIAL ANALYSIS] COMPLETED\n\n";

	print "[COBOL DEEP ANALYSIS] START (DEPTH CNT: $depth)\n";

	# More depth
	foreach ( 1 .. $depth ) {
		$new_calltree_pgm_list = uniq($calltree_pgm_list);
		$new_calltree_pgm_list =~ s/(.+): //g;
		base::cobol_search( uniq($new_calltree_pgm_list), "cobol", 0 );
	}
	print "[COBOL DEEP ANALYSIS] COMPLETED\n\n";

	file::save_file( uniq($calltree_missing_parm_list),
		$calltree_missing_parm_lst, 1 );
	file::save_file( uniq($calltree_missing_pgm_list),
		$calltree_missing_pgm_lst, 1 );
	file::save_file( uniq($calltree_missing_copy_list),
		$calltree_missing_copy_lst, 1 );
	file::save_file( uniq($calltree_missing_include_list),
		$calltree_missing_include_lst, 1 );
	file::save_file( uniq($calltree_pgm_list),     $calltree_pgm_lst,     1 );
	file::save_file( uniq($calltree_parm_list),    $calltree_parm_lst,    1 );
	file::save_file( uniq($calltree_copy_list),    $calltree_copy_lst,    1 );
	file::save_file( uniq($calltree_include_list), $calltree_include_lst, 1 );
	file::save_file( uniq($note_list),             $note_lst,             0 );
	print "\nFor details, please refer to ./result directory.\n\n";
}

base::process();
