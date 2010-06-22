package GAL::Parser::basic_snp;

use strict;
use vars qw($VERSION);


$VERSION = '0.01';
use base qw(GAL::Parser);
use GAL::Reader::DelimitedLine;

=head1 NAME

GAL::Parser::basic_snp - Parse SNP files with basic information.

=head1 VERSION

This document describes GAL::Parser::basic_snp version 0.01

=head1 SYNOPSIS

    my $parser = GAL::Parser::basic_snp->new(file => 'snp.txt');

    while (my $feature_hash = $parser->next_feature_hash) {
	print $parser->to_basic_snp($feature_hash) . "\n";
    }

=head1 DESCRIPTION

L<GAL::Parser::basic_snp> provides a parser for basic snp files that
contain the following tab delimited columns: chromosome start end
reference_seq variant_seq.

=head1 Constructor

New L<GAL::Parser::basic_snp> objects are created by the class method
new.  Arguments should be passed to the constructor as a list (or
reference) of key value pairs.  All attributes of the Parser object
can be set in the call to new. An simple example of object creation
would look like this:

    my $parser = GAL::Parser::basic_snp->new(file => 'data/snp.txt');

The constructor recognizes the following parameters which will set the
appropriate attributes:

=item * C<< file => feature_file.txt >>

This optional parameter provides the filename for the file containing
the data to be parsed. While this parameter is optional either it, or
the following fh parameter must be set.

=item * C<< fh => feature_file.txt >>

This optional parameter provides a filehandle to read data from. While
this parameter is optional either it, or the following fh parameter
must be set.

=cut

#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::Parser::basic_snp->new();
     Function: Creates a GAL::Parser::basic_snp object;
     Returns : A GAL::Parser::basic_snp object
     Args    : See the attributes described above.

=cut

sub new {
	my ($class, @args) = @_;
	my $self = $class->SUPER::new(@args);
	return $self;
}

#-----------------------------------------------------------------------------

sub _initialize_args {
	my ($self, @args) = @_;

	######################################################################
	# This block of code handels class attributes.  Use the
	# @valid_attributes below to define the valid attributes for
	# this class.  You must have identically named get/set methods
	# for each attribute.  Leave the rest of this block alone!
	######################################################################
	my $args = $self->SUPER::_initialize_args(@args);
	my @valid_attributes = qw(); # Set valid class attributes here
	$self->set_attributes($args, @valid_attributes);
	######################################################################

	# Set the column headers from your incoming data file here
	# These will become the keys in your $record hash reference below.
	$self->fields([qw(chromosome start end reference_seq variant_seq)]);
}

#-----------------------------------------------------------------------------

=head2 parse_record

 Title   : parse_record
 Usage   : $a = $self->parse_record();
 Function: Parse the data from a record.
 Returns : A hash ref needed by Feature.pm to create a Feature object
 Args    : A hash ref of fields that this sub can understand.

=cut

sub parse_record {
	my ($self, $record) = @_;

	# $self->throw(message => 'This parser should be tested and evaluated before use');

	my $seqid      = $record->{chromosome};
	my $source     = 'GAL';
	my $type       = 'SNV';
	my $start      = $record->{start};
	my $end        = $record->{end};
	my $score      = '.';
	my $strand     = '+';
	my $phase      = '.';
	my $id         = join ':', ($seqid, $source, $type, $start);

	my $reference_seq = $record->{reference_seq};
	my @variant_seqs  = $self->expand_iupac_nt_codes($record->{variant_seq});
	my $genotype = scalar @variant_seqs > 1 ? 'heterozygous' : 'homozygous';

	my $attributes = {Variant_seq   => \@variant_seqs,
			  Reference_seq => [$reference_seq],
			  ID            => [$id],
			  Genotype      => [$genotype],
			 };

	my $feature_data = {feature_id => $id,
			    seqid      => $seqid,
			    source     => $source,
			    type       => $type,
			    start      => $start,
			    end        => $end,
			    score      => $score,
			    strand     => $strand,
			    phase      => $phase,
			    attributes => $attributes,
			   };

	return $feature_data;
}

#-----------------------------------------------------------------------------

=head2 foo

 Title   : foo
 Usage   : $a = $self->foo();
 Function: Get/Set the value of foo.
 Returns : The value of foo.
 Args    : A value to set foo to.

=cut

sub foo {
	my ($self, $value) = @_;
	$self->{foo} = $value if defined $value;
	return $self->{foo};
}

#-----------------------------------------------------------------------------

=head1 DIAGNOSTICS

=for author to fill in:
     List every single error and warning message that the module can
     generate (even the ones that will "never happen"), with a full
     explanation of each problem, one or more likely causes, and any
     suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

<GAL::Parser::basic_snp> requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to:
barry.moore@genetics.utah.edu

=head1 AUTHOR

Barry Moore <barry.moore@genetics.utah.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Barry Moore <barry.moore@genetics.utah.edu>.  All rights reserved.

    This module is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

1;
