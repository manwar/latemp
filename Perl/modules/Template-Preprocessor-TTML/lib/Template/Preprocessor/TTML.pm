package Template::Preprocessor::TTML;

use warnings;
use strict;

use base 'Template::Preprocessor::TTML::Base';

use Template;
use Template::Preprocessor::TTML::CmdLineProc;

__PACKAGE__->mk_accessors(qw(
    argv
    opts
));

=head1 NAME

Template::Preprocessor::TTML - Preprocess files using the Template Toolkit
from the command line.

=cut

our $VERSION = '0.0103';

=head1 SYNOPSIS

    use Template::Preprocessor::TTML;

    my $obj = Template::Preprocessor::TTML->new(argv => [@ARGV]);
    $obj->run()

    ...

=head1 FUNCTIONS

=head2 initialize()

Internal function for initializing the object.

=cut

sub initialize
{
    my $self = shift;
    my %args = (@_);
    $self->argv([@{$args{'argv'}}]);

    return 0;
}

=head2 run

Performs the processing.

=cut

sub _calc_opts
{
    my $self = shift;
    my $cmd_line = Template::Preprocessor::TTML::CmdLineProc->new(argv => $self->argv());
    $self->opts($cmd_line->get_result());
}

sub _get_output
{
    my $self = shift;
    if ($self->opts()->output_to_stdout())
    {
        return ();
    }
    else
    {
        return ($self->opts()->output_filename());
    }
}

sub _get_mode_callbacks
{
    return {
        'regular' => "_mode_regular",
        'help' => "_mode_help",
        'version' => "_mode_version",
    };
}

sub _mode_version
{
    print <<"EOF";
This is TTML version $VERSION
TTML is a Command Line Preprocessor based on the Template Toolkit
(http://www.template-toolkit.org/)

More information about TTML can be found at:

http://search.cpan.org/dist/Template-Preprocessor-TTML/
EOF
}

sub _get_help_text
{
    return <<"EOF";
ttml - A Template Toolkit Based Preprocessor
Usage: ttml [-o OUTPUTFILE] [OPTIONS] INPUTFILE

Options:
    -o OUTPUTFILE - Output to file instead of stdout.
    -I PATH, --include=PATH - Append PATH to the include path
    -DVAR=VALUE, --define=VAR=VALUE - Define a pre-defined variable.
    --includefile=FILE - Include FILE at the top.

    -V, --version - display the version number.
    -h, --help - display this help listing.
EOF
}

sub _mode_help
{
    my $self = shift;

    print $self->_get_help_text();

    return 0;
}

sub run
{
    my $self = shift;
    $self->_calc_opts();

    return $self->can(
        $self->_get_mode_callbacks()->{$self->opts()->run_mode()}
    )->($self);
}

sub _mode_regular
{
    my $self = shift;
    my $config =
    {
        INCLUDE_PATH => [ @{$self->opts()->include_path()}, ".", ],
        EVAL_PERL => 1,
        PRE_PROCESS => $self->opts()->include_files(),
    };
    my $template = Template->new($config);

    if (!
        $template->process(
            $self->opts()->input_filename(),
            $self->opts()->defines(),
            $self->_get_output(),
        )
    )
    {
        die $template->error();
    }
}

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/> .

=head1 BUGS

Please report any bugs or feature requests to
C<bug-template-preprocessor-ttml@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Template-Preprocessor-TTML>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Shlomi Fish, all rights reserved.

This program is released under the MIT X11 License.

=cut

1;

