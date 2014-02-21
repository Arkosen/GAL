package GAL::Parser::snpeff;

use strict;
use vars qw($VERSION);
$VERSION = 0.2.0;

use base qw(GAL::Parser);
use GAL::Reader::DelimitedLine;

=head1 NAME

GAL::Parser::snpeff - <One line description of module's purpose here>

=head1 VERSION

This document describes GAL::Parser::snpeff version 0.2.0

=head1 SYNOPSIS

     use GAL::Parser::snpeff;

=for author to fill in:
     Brief code example(s) here showing commonest usage(s).
     This section will be as far as many users bother reading
     so make it as educational and exemplary as possible.

=head1 DESCRIPTION

=for author to fill in:
     Write a full description of the module and its features here.
     Use subsections (=head2, =head3) as appropriate.

=head1 METHODS

=cut

#-----------------------------------------------------------------------------

=head2 new

     Title   : new
     Usage   : GAL::Parser::snpeff->new();
     Function: Creates a GAL::Parser::snpeff object;
     Returns : A GAL::Parser::snpeff object
     Args    :

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
	my @valid_attributes = qw(file fh header_count); # Set valid class attributes here
	$self->set_attributes($args, @valid_attributes);
	######################################################################
}

#-----------------------------------------------------------------------------

sub header_count {
    my ($self, $header_count) = @_;

    if ($header_count) {
	$self->{header_count} = $header_count;
    }
    return $self->{header_count};
}

#-----------------------------------------------------------------------------

=head2 parse_record

 Title   : parse_record
 Usage   : $a = $self->parse_record();
 Function: Parse the data from a record.
 Returns : A hash ref needed by Feature.pm to create a Feature object
 Args    : A hash ref of fields that this sub can understand (In this case GFF3).

=cut

sub parse_record {
    my ($self, $data) = @_;

    ##fileformat=VCFv4.0
    ##INFO=<ID=DP,Number=1,Type=Integer,Description="Total Depth">
    ##INFO=<ID=HM2,Number=0,Type=Flag,Description="HapMap2 membership">
    ##INFO=<ID=HM3,Number=0,Type=Flag,Description="HapMap3 membership">
    ##reference=human_b36_both.fasta
    ##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
    ##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Read Depth">
    ##FORMAT=<ID=CB,Number=1,Type=String,Description="Called by S(Sanger), M(UMich), B(BI)">
    ##rsIDs=dbSNP b129 mapped to NCBI 36.3, August 10, 2009
    ##INFO=<ID=AC,Number=.,Type=Integer,Description="Allele count in genotypes">
    ##INFO=<ID=AN,Number=1,Type=Integer,Description="Total number of alleles in called genotypes">
    #CHROM POS ID REF ALT QUAL FILTER INFO FORMAT SAMPLE1

    my %record;

    # We didn't get $data as a hash because we didn't give field names to the reader.
    # This allows us to get the data as an array and deal with multiple genotypes per line.
    @record{qw(chrom pos id ref alt qual filter info format)} = splice(@{$data}, 0, 9);

    my $seqid      = $record{chrom}; # =~ /^chr/ ? $record{chrom} : 'chr' . $record{chrom};
    my $source     = '.';
    my $type       = 'SNV';
    my $start      = $record{pos};
    my $end        = $start;
    my $score      = $record{qual};
    my $strand     = '+',
    my $phase      = '.';
    my $feature_id = $record{id};

    #Validate var
    my $reference_seq = uc $record{ref};

    my @variant_seqs = split /,/, $record{alt};

    map {$_ = uc $_} @variant_seqs;

    my @all_seqs = ($reference_seq, @variant_seqs);




    # INFO Column Keys
    # VFC 4.0
    # AA ancestral allele
    # AC allele count in genotypes, for each ALT allele, in the same order as listed
    # AF allele frequency for each ALT allele in the same order as listed: use this when estimated from primary data, not called genotypes
    # AN total number of alleles in called genotypes
    # BQ RMS base quality at this position
    # CIGAR cigar string describing how to align an alternate allele to the reference allele
    # DB dbSNP membership
    # DP combined depth across samples, e.g. DP=154
    # END end position of the variant described in this record (esp. for CNVs)
    # H2 membership in hapmap2
    # MQ RMS (root mean square) mapping quality, e.g. MQ=52
    # MQ0 Number of MAPQ == 0 reads covering this record
    # NS Number of samples with data
    # SB strand bias at this position
    # SOMATIC indicates that the record is a somatic mutation, for cancer genomics
    # VALIDATED validated by follow-up experiment

    #INFO=<ID=EFF,Number=.,Type=String,Description="Predicted effects for this variant.Format:

    # Effect
    # 	    CODON_CHANGE_PLUS_CODON_DELETION
    # 	    CODON_CHANGE_PLUS_CODON_INSERTION
    # 	    CODON_DELETION
    # 	    CODON_INSERTION
    # 	    DOWNSTREAM
    # 	    EXON
    # 	    FRAME_SHIFT
    # 	    INTERGENIC
    # 	    INTRON
    # 	    NON_SYNONYMOUS_CODING
    # 	    START_GAINED
    # 	    START_LOST
    # 	    STOP_GAINED
    # 	    SYNONYMOUS_CODING
    # 	    UPSTREAM
    # 	    UTR_3_PRIME
    # 	    UTR_5_PRIME
    # Effect_Impact
    #       HIGH
    #	    LOW
    #	    MODERATE
    #	    MODIFIER
    # Functional_Class
    #       NONE
    #       MISSENSE
    #	    NONSENSE
    #	    SILENT
    # Codon_Change |
    # Amino_Acid_change|
    # Amino_Acid_length |
    # Gene_Name |
    # Transcript_BioType |
    #       antisense
    #	    IG_V_gene
    #	    lincRNA
    #	    miRNA
    #	    misc_RNA
    #	    nonsense_mediated_decay
    #	    processed_pseudogene
    #	    processed_transcript
    #	    protein_coding
    #	    pseudogene
    #	    retained_intron
    #	    rRNA
    #	    scRNA_pseudogene
    #	    sense_intronic
    #	    snoRNA
    #	    snoRNA_pseudogene
    #	    snRNA
    #	    snRNA_pseudogene
    #	    transcribed_unprocessed_pseudogene
    #	    tRNA_pseudogene
    #	    unprocessed_pseudogene
    # Gene_Coding |
    # Transcript_ID |
    # Exon |
    # GenotypeNum |
    # [ERRORS | WARNINGS ]

    my %info;
    my @pairs = split /;/, $record{info};
    for my $pair (@pairs) {
	my ($key, $value) = split /=/, $pair;
	$value = defined $value ? $value : '';
	my @values = split /,/, $value;
	push @{$info{$key}}, @values;
    }

    my @variant_effects;
    if (exists $info{EFF}) {
	my $effects = $info{EFF};
	for my $effect (@{$effects}) {
	    $effect =~ s/\)$//;
	    my @value_list = split /\||\(/, $effect, 13;
	    my %effect_hash;
	    @effect_hash{qw(
			   Effect
		       	   Effect_impact
		       	   Functional_class
		       	   Codon_Change
		       	   Amino_Acid_change
		       	   Amino_Acid_length
		       	   Gene_name
		       	   Transcript_bioType
		       	   Gene_Coding
		       	   Transcript_ID
		       	   Exon
		       	   Genotype
		       	   Warnings_Errors
		       	   )} = @value_list;

	    if ($effect_hash{Effect} eq 'INTERGENIC') {
		# intergenic_variant
		my $sequence_variant = 'intergenic_variant';
		my $sequence_feature = 'intergenic_region';
		my $variant_effect = join ' ', ($sequence_variant,
						$effect_hash{Genotype} - 1,
						$sequence_feature);
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'UPSTREAM') {
		# 'upstream_gene_variant'
		my $sequence_variant = 'upstream_gene_variant';
		my $sequence_feature = 'gene';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Gene_name});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'UTR_5_PRIME') {
		# '5_prime_UTR_variant'
		my $sequence_variant = '5_prime_UTR_variant';
		my $sequence_feature = 'five_prime_UTR';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'UTR_5_DELETED') {
		# '5_prime_UTR_variant'
		my $sequence_variant = '5_prime_UTR_variant';
		my $sequence_feature = 'five_prime_UTR';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;

		# feature_ablation
		$sequence_variant = 'feature_ablation';
		$sequence_feature = 'five_prime_UTR';
		$variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'START_GAINED') {
		# '5_prime_UTR_premature_start_codon_variant'
		my $sequence_variant = '5_prime_UTR_premature_start_codon_variant';
		my $sequence_feature = 'five_prime_UTR';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'SPLICE_SITE_ACCEPTOR') {
		# 'splice_acceptor_variant'
		my $sequence_variant = 'splice_acceptor_variant';
		my $sequence_feature = 'splice_acceptor';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'SPLICE_SITE_DONOR') {
		# 'splice_donor_variant'
		my $sequence_variant = 'splice_donor_variant';
		my $sequence_feature = 'splice_donor';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'START_LOST') {
		# initiator_codon_variant
		my $sequence_variant = 'initiator_codon_variant';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
		
		# missense_variant
		$sequence_variant = 'missense_variant';
		$sequence_feature = 'mRNA';
		$variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
	    }
	    elsif ($effect_hash{Effect} eq 'SYNONYMOUS_START') {
		# initiator_codon_variant
		my $sequence_variant = 'initiator_codon_variant';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
		
		# synonymous_variant
		$sequence_variant = 'synonymous_variant';
		$sequence_feature = 'mRNA';
		$variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'CDS') {
		# 'coding_sequence_variant'
		my $sequence_variant = 'coding_sequence_variant';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'GENE') {
		# 'gene_variant'
		my $sequence_variant = 'gene_variant';
		my $sequence_feature = 'gene';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'TRANSCRIPT') {
		# 'transcript_variant'
		my $sequence_variant = 'transcript_variant';
		my $sequence_feature = 'transcript';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'EXON') {
		# 'exon_variant'
		my $sequence_variant = 'exon_variant';
		my $sequence_feature = 'exon';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'EXON_DELETED') {
		# feature_ablation
		my $sequence_variant = 'feature_ablation';
		my $sequence_feature = 'exon';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
		
		# exon_variant
		$sequence_variant = 'exon_variant';
		$sequence_feature = 'exon';
		$variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'NON_SYNONYMOUS_CODING') {
		# 'missense_variant'
		my $sequence_variant = 'missense_variant';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'SYNONYMOUS_CODING') {
		# 'synonymous_variant'
		my $sequence_variant = 'synonymous_variant';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'FRAME_SHIFT') {
		# 'frameshift_variant'
		my $sequence_variant = 'frameshift_variant';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'CODON_CHANGE') {
		# 'inframe_variant'
		my $sequence_variant = 'inframe_variant';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'CODON_INSERTION') {
		# 'conservative_inframe_insertion'
		my $sequence_variant = 'conservative_inframe_insertion';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'CODON_CHANGE_PLUS_CODON_INSERTION') {
		# 'disruptive_inframe_insertion'
		my $sequence_variant = 'disruptive_inframe_insertion';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'CODON_DELETION') {
		# 'conservative_inframe_deletion'
		my $sequence_variant = 'conservative_inframe_deletion';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'CODON_CHANGE_PLUS_CODON_DELETION') {
		# 'disruptive_inframe_deletion'
		my $sequence_variant = 'disruptive_inframe_deletion';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'STOP_GAINED') {
		# 'stop_gained'
		my $sequence_variant = 'stop_gained';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'SYNONYMOUS_STOP') {
		# 'stop_retained_variant'
		my $sequence_variant = 'stop_retained_variant';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'STOP_LOST') {
		# 'stop_lost'
		my $sequence_variant = 'stop_lost';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'INTRON') {
		# 'intron_variant'
		my $sequence_variant = 'intron_variant';
		my $sequence_feature = 'intron';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'UTR_3_PRIME') {
		# '3_prime_UTR_variant'
		my $sequence_variant = '3_prime_UTR_variant';
		my $sequence_feature = 'three_prime_UTR';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'UTR_3_DELETED') {
		# '3_prime_UTR_variant'
		my $sequence_variant = '3_prime_UTR_variant';
		my $sequence_feature = 'three_prime_UTR';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
		
		# feature_ablation
		my $sequence_variant = 'feature_ablation';
		my $sequence_feature = 'three_prime_UTR';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'DOWNSTREAM') {
		# 'downstream_gene_variant'
		my $sequence_variant = 'downstream_gene_variant';
		my $sequence_feature = 'gene';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Gene_name});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'INTRON_CONSERVED') {
		# 'intron_variant'
		my $sequence_variant = 'intron_variant';
		my $sequence_feature = 'intron';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
		
		# conserved_region
		my $sequence_variant = 'sequence_variant';
		my $sequence_feature = 'conserved_region';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature);
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'INTERGENIC_CONSERVED') {
		# 'intergenic_region'
		my $sequence_variant = 'intergenic_region_variant';
		my $sequence_feature = 'intergenic_region';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature);
		push @variant_effects, $variant_effect;
		
		# conserved_region
		my $sequence_variant = 'sequence_variant';
		my $sequence_feature = 'conserved_region';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature);
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'INTRAGENIC') {
		# 'gene_variant'
		my $sequence_variant = 'gene_variant';
		my $sequence_feature = 'gene';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Gene_name});
		push @variant_effects, $variant_effect;
	    }
	    elsif ($effect_hash{Effect} eq 'NON_SYNONYMOUS_START') {
		# initiator_codon_variant
		my $sequence_variant = 'initiator_codon_variant';
		my $sequence_feature = 'mRNA';
		my $variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
		push @variant_effects, $variant_effect;
		
		# missense_variant
		$sequence_variant = 'missense_variant';
		$sequence_feature = 'mRNA';
		$variant_effect   = join ' ', ($sequence_variant, $effect_hash{Genotype} - 1, $sequence_feature, $effect_hash{Transcript_ID});
	    }
	    else {
		$self->warn('unknown_variant_type', $effect_hash{Effect});
	    }
	}
    }
    
    my @all_seqs = ($reference_seq, @variant_seqs);
    my @lengths = map {length($_)} @all_seqs;

    #INDEL
    if (grep {$_ != 1} @lengths) {
	my ($min_length) = sort {$a <=> $b} @lengths;
	map {substr($_, 0, $min_length, '')} @all_seqs;
	map {$_ ||= '-'} @all_seqs;
	my $start_adjust = length($reference_seq) - length($all_seqs[0]);
	$start += $start_adjust;
	my $end_adjust = length($all_seqs[0]) - 1;
	$end = $start + $end_adjust;
	
	$reference_seq = shift @all_seqs;
	@variant_seqs = @all_seqs;
	
	if ($reference_seq eq '-') {
	    $type = 'insertion';
	}
	elsif (grep {$_ eq '-'} @variant_seqs) {
	    $type = 'deletion';
	}
	else {
	    $type = 'complex_substitution';
	}
    }
    
    my $read_count = $info{DP}[0] || undef;
    
    # Make sure that at least one variant sequence differs from
    # the reference sequence.
    next unless grep {$_ ne $reference_seq} @variant_seqs;
    
    # Format Column Keys
    # GT : genotype, encoded as alleles values separated by either of
    # ”/” or “|”, e.g. The allele values are 0 for the reference
    # allele (what is in the reference sequence), 1 for the first
    # allele listed in ALT, 2 for the second allele list in ALT and
    # so on. For diploid calls examples could be 0/1 or 1|0 etc. For
    # haploid calls, e.g. on Y, male X, mitochondrion, only one
    # allele value should be given. All samples must have GT call
    # information; if a call cannot be made for a sample at a given
    # locus, ”.” must be specified for each missing allele in the GT
    # field (for example ./. for a diploid). The meanings of the
    # separators are:
    #       / : genotype unphased
    #       | : genotype phased
    # DP : read depth at this position for this sample (Integer)
    # FT : sample genotype filter indicating if this genotype was
    # “called” (similar in concept to the FILTER field). Again, use
    # PASS : to indicate that all filters have been passed, a
    # semi-colon separated list of codes for filters that fail, or
    # ”.” to indicate that filters have not been applied. These
    # values should be described in the meta-information in the same
    # way as FILTERs (Alphanumeric String)
    # GL : three floating point log10-scaled likelihoods for
    # AA,AB,BB genotypes where A=ref and B=alt; not applicable if
    # site is not biallelic. For example: GT:GL
    # 0/1:-323.03,-99.29,-802.53 (Numeric)
    # GQ : genotype quality, encoded as a phred quality
    # -10log_10p(genotype call is wrong) (Numeric)
    # HQ : haplotype qualities, two phred qualities comma separated
    # (Numeric)
    
    my $feature_id = join ':', ($seqid, $source, $start);
    
    my $attributes = {Reference_seq => [$reference_seq],
		      Variant_seq   => \@variant_seqs,
		      ID            => [$feature_id],
    };
    $attributes->{Total_reads} = [$read_count] if $read_count;
    $attributes->{Variant_effect} = \@variant_effects
	if scalar @variant_effects;
    
    my $feature = {feature_id => $feature_id,
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
     return $feature;
}

#-----------------------------------------------------------------------------

sub reader {
    my $self = shift;


    if (! $self->{reader}) {
	# We don't give field names here so that the record will be returned
	# as an array rather than a hash.  We splice out the first
	# 9 columns above and the rest in genotype data.
	# my @field_names = qw(chrom pos id ref alt qual filter info format);
	my $reader = GAL::Reader::DelimitedLine->new(comment_pattern => qr/^\#\#/,
						     header_count    => 1
						     );
	$self->{reader} = $reader;
    }
    return $self->{reader};
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

<GAL::Parser::snpeff> requires no configuration files or environment variables.

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
