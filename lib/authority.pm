package authority;

use 5.005;
use strict;
use UNIVERSAL::AUTHORITY 0.001 qw[];

BEGIN {
	$authority::AUTHORITY = 'cpan:TOBYINK';
	$authority::VERSION   = '0.001';
}

use Carp 1.0 qw[];
use File::Spec 0.6 qw[];
use Scalar::Util 0 qw[blessed refaddr];

sub import
{
	my ($class, $authority, $module, @arguments) = @_;
	($module, my $version) = split /\s+/, $module, 2;
	Carp::croak("Wrong number of arguments") unless defined $authority;

	(my $file = "$module.pm") =~ s!::!/!g;

	if ($authority =~ /^any$/i)
	{
		require $file;
	}
	else
	{
		my $authority_file = $authority;
		$authority_file =~ s/([^A-Za-z0-9])/sprintf('_%02X_', ord($1))/eg;
		$authority_file = File::Spec->catfile($authority_file, $file);
		eval { require $authority_file; 1 } or require $file;
	}
	
	CHECKS: do {
		$Carp::CarpLevel++;
		$module->AUTHORITY($authority)
			unless $authority =~ /^any$/i;
		$module->VERSION($version)
			if defined $version;
		$Carp::CarpLevel--;
	};
	
	my $method = $module->can('import');
	@_ = ($module, @arguments);
	goto &$method if $method;
}

1;

__END__

=head1 NAME

authority - loads a module only if it has a particular authority

=head1 SYNOPSIS

 use authority 'cpan:STEVAN', Moose => qw();
 use authority 'cpan:TOBYINK', HTML::HTML5::Builder => qw(:standard);

=head1 DESCRIPTION

This pragma allows you to indicate that you wish to load a module only
if its authority is a particular URI.

Using this pragma automatically enables L<UNIVERSAL::AUTHORITY>.

=over

=item C<< use authority $authority, $module, @arguments >>

Require and import the module at compile time. This is the usual mode
of operation.

=item C<< authority->import($authority, $module, @arguments) >>

Require and import the module at run time. 

=back

Note that the special C<$authority> value "Any", indicates that any
authority is allowed (including undef).

Experimentally, C<$module> may contain a module name and minimum version,
separated with a space.

There is also a very experimental feature allowing releases of the
same package by different authorities to live side-by-side, though
only one of them can be required into a running script.

In this case, assuming that the inc path is C</opt/perl/lib> and a
script does this:

 use authority 'cpan:JOE', My::Module => qw();

Then Perl will attempt to load C</opt/perl/lib/cpan_3A_JOE/My/Module.pm>
before it tries the usual C</opt/perl/lib/My/Module.pm>.

This is not anywhere near as powerful as the authority feature of Perl 6,
but it's a start.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=authority>.

=head1 SEE ALSO

L<UNIVERSAL::AUTHORITY>,
L<authority::shared>,
L<http://feather.perl6.nl/syn/S11.html>,
L<http://www.perlmonks.org/?node_id=694377>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2011 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

