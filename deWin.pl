#!/usr/bin/perl -w
#----------------------------------------------------------------------------->
#	deWin.pl                                                                  >	
#	Perl Script to de-Win Directory Contents                                  >
#	(i.e. Remove Whitespace, Special Characters, etc From File/Dir Names)     >
#	by: Jason Balthis	11/27/2013                                        >
#----------------------------------------------------------------------------->

# Use target directory if user-specified
# otherwise current working directory is used
$path = $ARGV[0];

if($path){
	# open user defined directory and read its contents into @files
	opendir(DIR, $path) or die $!;
	@files = readdir(DIR) or die $!;
}
else {
	# open current working directory and read its contents into @files
	@files = <*> or die $!;
}

# Subroutine to apply regex's to our file and directory names
sub DeWin
	{
		# Assign the file or directory name to $arg
		($arg) = @_;
		
		# The inverse of the characters we are including
		# which is the ones we are excluding
		$not_allowed = '[^\d\w\.\-\~\"\']+';
		
		# No duplicate symbols or symbol neighbors
		$no_dups = '[\_\-\.\~\"\']+';
		
		# Remove leading non-word characters
		$head = '^(\W)|^(\_)';
		
		# Remove trailing non-word characters
		$tail = '(\W)$|(\.)$|(\_)$';
		
		# Run the operations on the $arg
		$arg =~ s/$not_allowed/\_/g;
		$arg =~ s/($no_dups)($no_dups)/$1/g;
		$arg =~ s/($no_dups)($no_dups)/$2/g;
		$arg =~ s/$head//g;
		$arg =~ s/$tail//g;
		
		# Return the modified $arg
		return $arg or die $!;
	
	}

# Loop through all entries in the directory we are working on
foreach $file (@files) {
	
	# Get the length of current item
	$length = length($file);
	
	# Put our name into a variable
	$me = "deWin.pl";

	# Ensure we don't modify ourself and that $file is not a directory
	if($file !~ $me && !(-d($file))){
		
		# Check for last occurence of a period before 
		# the end $file's name indicating an extension
		$period = rindex($file,".");
		
		# Account for $file with extension
		if($period != -1){
		
			# Place file extension in a variable
			# and deal with unwanted characters
			$ext = substr($file,$period+1,$length);
			$ext = DeWin($ext) or die $!;
			
			# Place file name in a variable
			# and deal with unwanted characters
			$tmp = substr($file,0,$period);
			$tmp = DeWin($tmp);
			$tmp .= "." . $ext;		
		}
		
		# Case for $file with no extension 
		else{
			$tmp = $file;
			$tmp = DeWin($tmp);	
		}
		
		# Rename file
		rename($file,$tmp);
	}
	
	# If $file is a directory
	else {
		
		# Again, make sure we aren't working on ourself
		if($file !~ $me) {
			
			# Place directory name in a variable
			# and deal with unwanted characters
			$tmp = $file;
			$tmp = DeWin($tmp);
			
			# Rename directory
			rename($file,$tmp);
		}
	}
}
closedir(DIR) or die $!;
exit 0;
