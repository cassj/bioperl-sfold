# ABSTRACT: what this module is for
=head1 NAME

Bio::Tools::Run::Sfold - quick description

=head1 SYNOPSIS

# Synopsis code demonstrating the module goes here

=head1 DESCRIPTION

A description about this module.

=cut 
use strict;
use warnings;
package Bio::Tools::Run::Sfold;

use base 'Bio::Tools::Run::WrapperBase::Accessor';

__PACKAGE__->_setup
  (
   '-params'   => {
		   'a'  => 'Run clustering on the sampled ensembl. 1 or 0. Default 1',
		   'f'  => 'Name of a file containing folding constraints. Syntax as per mfold 3.1. Default is no constraint',
		   'l'  => 'Maximum distance between paired bases. Positive integer. Default is no limit.',
		   'm'  => 'Name of file containing the MFE structure in GCG connect format. If provided, Sfold clustering module will determine the cluster to which this structure belongs',
		   'o'  => 'Name of directory to which output files are written. A tempdir by default.',
		   'w'  => 'Length of antisense oligos. Positive integer. Default 20'
		  }
   '-switches' => {
		  }
  );


=head2 new

  Title    : new
  Usage    : my $folder = Bio::Tools::Run::Sfold->new();
  Function : Constructor
  Returns  : An object of class Bio::Tools::Run::Sfold
  Args     : Any of the command line parameters can be passed to the 
             constructor. It will also accept -program_dir and -program_name

=cut

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_); 
  bless $self, $class;

  # setup program dir and name
  my ($pd, $pn) =  $self->_rearrange(['program_dir', 'program_name'], @_);
  $pd = $ENV{SFOLD_DIR} unless $pd;
  $self->{program_dir} = $pd if $pd;

  $self->{program_name} = $pn || 'sfold.pl';

  return $self;

}


=head2 program_name

  Title    : program_name
  Usage    : $folder->program_name
  Function : returns the name of the executable
  Returns  : string
  Args     : none

=cut

sub program_name{
  my $self = shift;
  return $self->{program_name};
}
  

=head2 program_dir

  Title    : program_dir
  Usage    : my $path = $folder->program_dir;
  Function : Returns the current program_dir, the location in which 
             the Sfold executables can be found, if one is defined.
             You can define the program_dir by setting the 
             $SFOLD_DIR environment variable, or by passing a path
             to the -program_dir parameter of ->new().
             If left undefined, the system $PATH will be searched.
  Returns  : A path, or undef
  Args     : none

=cut

sub program_dir{
    my $self = shift;   
    return $self->{program_dir};
}


=head2 version

  Title    : version
  Usage    : $folder->version;
  Function : returns the hybrid-ss-min version
  Returns  : A string
  Args     : None

=cut

sub version{
    my $self = shift;
    return;
}



=head2 run

  Title    : run
  Usage    : $folder->run($bioseq_object, $bioseq_object, ...);
  Function : Run the executable with the set parameters
  Returns  : The location of the output files.
  Args     : None

=cut

sub run {

  my $self = shift;
  my @seqs  = @_;

  $self->throw('No sequences provided') unless scalar @seqs;

  my $tempdir = $self->tempdir;
  my $seqfile = "$tempdir/sequences.txt";
  my $seq_out = Bio::SeqIO->new('-file' => ">$seqfile",
				'-format' => 'raw');
  foreach(@seqs){
    $seq_out->write_seq($_);
  }

  my $exe = $self->executable;
  $self->throw("$exe was not found.") unless -e $exe;
  $self->throw("$exe not executable.") unless -x $exe;

  my $param_string = $self->parameter_string(-double_dash=>1);
  my $exe_string = join " ", $exe, $param_string, $seqfile;

  my $outdir = $self->o || $tempdir;
  my $status = system("cd $outdir && $exe_string");

  return $exe_string;
}




=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to the
Bioperl mailing list. Your participation is much appreciated. 

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Reporting Bugs 

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via the
web:

  http://bugzilla.open-bio.org/  

=head1 AUTHOR - Cass Johnston <cassjohnston@gmail.com>

The author(s) and contact details should be included here (this insures you get credit for creating the module.  
Lesser contributions can be documented in a separate CONTRIBUTORS section if you prefer. 

=cut

1;
