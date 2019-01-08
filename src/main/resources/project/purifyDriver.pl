use warnings;
use strict; 
$|=1;

use ElectricCommander;

use constant RESULT_TYPE_TEXT => 'text';
use constant RESULT_TYPE_DATAFILE => 'pfy';

  #######################################################################
  # trim - deletes blank spaces before and after the entered value in 
  # the argument
  #
  # Arguments:
  #   -untrimmedString: string that will be trimmed
  #
  # Returns:
  #   trimmed string
  #
  ########################################################################  
  sub trim($) {
   
      my ($untrimmedString) = @_;
      
      my $string = $untrimmedString;
      
      #removes leading spaces
      $string =~ s/^\s+//;
      
      #removes trailing spaces
      $string =~ s/\s+$//;
      
      #returns trimmed string
      return $string;
  }

  
# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
my $ec = new ElectricCommander();
$ec->abortOnError(0);
  
$::gPurifyPath = trim($ec->getProperty("/myCall/purifypath")-> findvalue("//value")->value());
$::gTarget = trim($ec->getProperty("/myCall/target")-> findvalue("//value")->value());
$::gAutoMergeData = trim($ec->getProperty("/myCall/automerge")-> findvalue("//value")->value());
$::gRunCoverage = trim($ec->getProperty("/myCall/runcoverage")-> findvalue("//value")->value());
$::gDotNetApp = trim($ec->getProperty("/myCall/dotnet")-> findvalue("//value")->value());
$::gResultFile = trim($ec->getProperty("/myCall/resultfile")-> findvalue("//value")->value());
$::gResultFileName = trim($ec->getProperty("/myCall/resultname")-> findvalue("//value")->value());
$::gSourcePath = trim($ec->getProperty("/myCall/sourcepath")-> findvalue("//value")->value());
$::gAdditionalCommands = trim($ec->getProperty("/myCall/additionalcommands")-> findvalue("//value")->value());


########################################################################
# main - contains the whole process to be done by the plugin, it builds 
#        the command line, sets the properties and the working directory
#
# Arguments:
#   -none
#
# Returns:
#   -nothing
#
########################################################################
sub main() {
    
    # create args array
    my @args = ();
    
    #properties' map
    my %props;
    
    #executable to use
    my $executable = 'Purify';
    
    if($::gPurifyPath && $::gPurifyPath ne '' && $::gPurifyPath ne 'Purify') {
        $executable ='"'. $::gPurifyPath .'"';
    }
    
     #insert program to invoke
    push(@args, $executable);
    
    if($::gAdditionalCommands  && $::gAdditionalCommands  ne '') {
        foreach my $command (split(' +', $::gAdditionalCommands)) {
            push(@args, $command);
        }
    }

    if($::gAutoMergeData && $::gAutoMergeData ne '') {
        push(@args, '-AutoMergeData=yes');
    }else{
        push(@args, '-AutoMergeData=no');
    }
    
    if($::gResultFile && $::gResultFile ne ''){
        
        
        
        #evaluates the selected platform
        if($::gResultFile eq RESULT_TYPE_TEXT){
        
           if($::gResultFileName && $::gResultFileName ne ''){
               
               push(@args, '-SaveTextData=' .'"'. $::gResultFileName.'.txt'.'"');
               
            }
        }
        
         elsif($::gResultFile eq RESULT_TYPE_DATAFILE){
         
            push(@args, '-SaveData="'.$::gResultFileName.'.pfy'.'"');
            
        }
        
    }

    if($::gSourcePath && $::gSourcePath ne ''){
     
        push(@args, '-SourcePath="' . $::gSourcePath . '"');
     
    }
    
    if($::gRunCoverage && $::gRunCoverage ne '' &&  $::gDotNetApp ne "1") {
           push(@args, '-Coverage');
        
    }
    
    if($::gDotNetApp && $::gDotNetApp ne '') {
        push(@args, '-net');
    }    
    
    if($::gTarget && $::gTarget ne ''){
     
        push(@args, '"' . $::gTarget . '"')
     
    }

    #generate the command to execute in console
    $props{'commandLine'} = createCommandLine(\@args);
    
    setProperties(\%props);
    
}

########################################################################
# createCommandLine - creates the command line for the invocation
# of the program to be executed.
#
# Arguments:
#   -arr: array containing the command name and the arguments entered by 
#         the user in the UI
#
# Returns:
#   -the command line to be executed by the plugin
#
########################################################################
sub createCommandLine($) {

    my ($arr) = @_;

    my $commandName = @$arr[0];

    my $command = $commandName;

    shift(@$arr);

    foreach my $elem (@$arr) {
        $command .= " $elem";
    }

    return $command;
    
}

########################################################################
# setProperties - set a group of properties into the Electric Commander
#
# Arguments:
#   -propHash: hash containing the ID and the value of the properties 
#              to be written into the Electric Commander
#
# Returns:
#   -nothing
#
########################################################################
sub setProperties($) {

    my ($propHash) = @_;

    # get an EC object
    my $ec = new ElectricCommander();
    $ec->abortOnError(0);

    foreach my $key (keys % $propHash) {
        my $val = $propHash->{$key};
        $ec->setProperty("/myCall/$key", $val);
    }
}

main();

