# --
# Kernel/System/HTML2Ascii.pm - the global html <-> ascii tools
# Copyright (C) 2001-2009 OTRS AG, http://otrs.org/
# --
# $Id: HTML2Ascii.pm,v 1.10 2009-07-15 20:03:48 ub Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::HTML2Ascii;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.10 $) [1];

=head1 NAME

Kernel::System::HTML2Ascii - html <-> ascii converter

=head1 SYNOPSIS

A module to convert html <-> ascii strings.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::Config;
    use Kernel::System::Encode;
    use Kernel::System::Log;
    use Kernel::System::HTML2Ascii;

    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );
    my $HTML2AsciiObject = Kernel::System::HTML2Ascii->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get debug level from parent
    $Self->{Debug} = $Param{Debug} || 0;

    # check needed objects
    for (qw(LogObject ConfigObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    return $Self;
}

=item ToAscii()

convert a html string to an ascii string

    my $Ascii = $HTML2AsciiObject->ToAscii( String => $String );

=cut

sub ToAscii {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(String)) {
        if ( !defined $Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # find <a href=....> and replace it with [x]
    my $LinkList = '';
    my $Counter  = 0;
    $Param{String} =~ s{
        <a\Whref=("|')(.+?)("|')(|.+?)>
    }
    {
        my $Link = $2;
        $Counter++;
        $LinkList .= "[$Counter] $Link\n";
        "[$Counter]";
    }egxi;

    # remove empty lines
    $Param{String} =~ s/^\s*//mg;

    # fix some bad stuff from opera and others
    $Param{String} =~ s/(\n\r|\r\r\n|\r\n)/\n/gs;

    # replace new lines with one space
    $Param{String} =~ s/\n/ /gs;
    $Param{String} =~ s/\r/ /gs;

    # remove style tags
    $Param{String} =~ s/\<style.+?\>.*\<\/style\>//gsi;

    # remove br tags and replace it with \n
    $Param{String} =~ s/\<br(\/|)\>/\n/gsi;

    # remove hr tags and replace it with \n
    $Param{String} =~ s/\<(hr|hr.+?)\>/\n\n/gsi;

    # remove pre, p, table, code tags and replace it with \n
    $Param{String} =~ s/\<(\/|)(pre|pre.+?|p|p.+?|table|table.+?|code|code.+?)\>/\n\n/gsi;

    # remove tr, th tags and replace it with \n
    $Param{String} =~ s/\<(tr|tr.+?|th|th.+?)\>/\n\n/gsi;

    # convert li tags to \n -
    $Param{String} =~ s/\<li\>/\n - /gsi;

    # convert </ul> and </ol> tags to \n\n
    $Param{String} =~ s/\<\/(ul|ol)\>/\n\n/gsi;

    # remove td tags and replace it with \n
    $Param{String} =~ s/\.+?<\/(td|td.+?)\>/ /gsi;

    # strip all other tags
    $Param{String} =~ s/\<.+?\>//gs;

    # replace "  " with " " space
    $Param{String} =~ s/  / /mg;

    # html encode based from cpan's HTML::Entities v1.35
    my %Entity = (

        # Some normal chars that have special meaning in SGML context
        amp  => '&',    # ampersand
        'gt' => '>',    # greater than
        'lt' => '<',    # less than
        quot => '"',    # double quote
        apos => "'",    # single quote

        # PUBLIC ISO 8879-1986//ENTITIES Added Latin 1//EN//HTML
        AElig  => chr(198),    # capital AE diphthong (ligature)
        Aacute => chr(193),    # capital A, acute accent
        Acirc  => chr(194),    # capital A, circumflex accent
        Agrave => chr(192),    # capital A, grave accent
        Aring  => chr(197),    # capital A, ring
        Atilde => chr(195),    # capital A, tilde
        Auml   => chr(196),    # capital A, dieresis or umlaut mark
        Ccedil => chr(199),    # capital C, cedilla
        ETH    => chr(208),    # capital Eth, Icelandic
        Eacute => chr(201),    # capital E, acute accent
        Ecirc  => chr(202),    # capital E, circumflex accent
        Egrave => chr(200),    # capital E, grave accent
        Euml   => chr(203),    # capital E, dieresis or umlaut mark
        Iacute => chr(205),    # capital I, acute accent
        Icirc  => chr(206),    # capital I, circumflex accent
        Igrave => chr(204),    # capital I, grave accent
        Iuml   => chr(207),    # capital I, dieresis or umlaut mark
        Ntilde => chr(209),    # capital N, tilde
        Oacute => chr(211),    # capital O, acute accent
        Ocirc  => chr(212),    # capital O, circumflex accent
        Ograve => chr(210),    # capital O, grave accent
        Oslash => chr(216),    # capital O, slash
        Otilde => chr(213),    # capital O, tilde
        Ouml   => chr(214),    # capital O, dieresis or umlaut mark
        THORN  => chr(222),    # capital THORN, Icelandic
        Uacute => chr(218),    # capital U, acute accent
        Ucirc  => chr(219),    # capital U, circumflex accent
        Ugrave => chr(217),    # capital U, grave accent
        Uuml   => chr(220),    # capital U, dieresis or umlaut mark
        Yacute => chr(221),    # capital Y, acute accent
        aacute => chr(225),    # small a, acute accent
        acirc  => chr(226),    # small a, circumflex accent
        aelig  => chr(230),    # small ae diphthong (ligature)
        agrave => chr(224),    # small a, grave accent
        aring  => chr(229),    # small a, ring
        atilde => chr(227),    # small a, tilde
        auml   => chr(228),    # small a, dieresis or umlaut mark
        ccedil => chr(231),    # small c, cedilla
        eacute => chr(233),    # small e, acute accent
        ecirc  => chr(234),    # small e, circumflex accent
        egrave => chr(232),    # small e, grave accent
        eth    => chr(240),    # small eth, Icelandic
        euml   => chr(235),    # small e, dieresis or umlaut mark
        iacute => chr(237),    # small i, acute accent
        icirc  => chr(238),    # small i, circumflex accent
        igrave => chr(236),    # small i, grave accent
        iuml   => chr(239),    # small i, dieresis or umlaut mark
        ntilde => chr(241),    # small n, tilde
        oacute => chr(243),    # small o, acute accent
        ocirc  => chr(244),    # small o, circumflex accent
        ograve => chr(242),    # small o, grave accent
        oslash => chr(248),    # small o, slash
        otilde => chr(245),    # small o, tilde
        ouml   => chr(246),    # small o, dieresis or umlaut mark
        szlig  => chr(223),    # small sharp s, German (sz ligature)
        thorn  => chr(254),    # small thorn, Icelandic
        uacute => chr(250),    # small u, acute accent
        ucirc  => chr(251),    # small u, circumflex accent
        ugrave => chr(249),    # small u, grave accent
        uuml   => chr(252),    # small u, dieresis or umlaut mark
        yacute => chr(253),    # small y, acute accent
        yuml   => chr(255),    # small y, dieresis or umlaut mark

        # Some extra Latin 1 chars that are listed in the HTML3.2 draft (21-May-96)
        copy => chr(169),      # copyright sign
        reg  => chr(174),      # registered sign
        nbsp => chr(160),      # non breaking space

        # Additional ISO-8859/1 entities listed in rfc1866 (section 14)
        iexcl   => chr(161),
        cent    => chr(162),
        pound   => chr(163),
        curren  => chr(164),
        yen     => chr(165),
        brvbar  => chr(166),
        sect    => chr(167),
        uml     => chr(168),
        ordf    => chr(170),
        laquo   => chr(171),
        'not'   => chr(172),    # not is a keyword in perl
        shy     => chr(173),
        macr    => chr(175),
        deg     => chr(176),
        plusmn  => chr(177),
        sup1    => chr(185),
        sup2    => chr(178),
        sup3    => chr(179),
        acute   => chr(180),
        micro   => chr(181),
        para    => chr(182),
        middot  => chr(183),
        cedil   => chr(184),
        ordm    => chr(186),
        raquo   => chr(187),
        frac14  => chr(188),
        frac12  => chr(189),
        frac34  => chr(190),
        iquest  => chr(191),
        'times' => chr(215),    # times is a keyword in perl
        divide  => chr(247),

        (
            $] > 5.007
            ? (
                OElig    => chr(338),
                oelig    => chr(339),
                Scaron   => chr(352),
                scaron   => chr(353),
                Yuml     => chr(376),
                fnof     => chr(402),
                circ     => chr(710),
                tilde    => chr(732),
                Alpha    => chr(913),
                Beta     => chr(914),
                Gamma    => chr(915),
                Delta    => chr(916),
                Epsilon  => chr(917),
                Zeta     => chr(918),
                Eta      => chr(919),
                Theta    => chr(920),
                Iota     => chr(921),
                Kappa    => chr(922),
                Lambda   => chr(923),
                Mu       => chr(924),
                Nu       => chr(925),
                Xi       => chr(926),
                Omicron  => chr(927),
                Pi       => chr(928),
                Rho      => chr(929),
                Sigma    => chr(931),
                Tau      => chr(932),
                Upsilon  => chr(933),
                Phi      => chr(934),
                Chi      => chr(935),
                Psi      => chr(936),
                Omega    => chr(937),
                alpha    => chr(945),
                beta     => chr(946),
                gamma    => chr(947),
                delta    => chr(948),
                epsilon  => chr(949),
                zeta     => chr(950),
                eta      => chr(951),
                theta    => chr(952),
                iota     => chr(953),
                kappa    => chr(954),
                lambda   => chr(955),
                mu       => chr(956),
                nu       => chr(957),
                xi       => chr(958),
                omicron  => chr(959),
                pi       => chr(960),
                rho      => chr(961),
                sigmaf   => chr(962),
                sigma    => chr(963),
                tau      => chr(964),
                upsilon  => chr(965),
                phi      => chr(966),
                chi      => chr(967),
                psi      => chr(968),
                omega    => chr(969),
                thetasym => chr(977),
                upsih    => chr(978),
                piv      => chr(982),
                ensp     => chr(8194),
                emsp     => chr(8195),
                thinsp   => chr(8201),
                zwnj     => chr(8204),
                zwj      => chr(8205),
                lrm      => chr(8206),
                rlm      => chr(8207),
                ndash    => chr(8211),
                mdash    => chr(8212),
                lsquo    => chr(8216),
                rsquo    => chr(8217),
                sbquo    => chr(8218),
                ldquo    => chr(8220),
                rdquo    => chr(8221),
                bdquo    => chr(8222),
                dagger   => chr(8224),
                Dagger   => chr(8225),
                bull     => chr(8226),
                hellip   => chr(8230),
                permil   => chr(8240),
                prime    => chr(8242),
                Prime    => chr(8243),
                lsaquo   => chr(8249),
                rsaquo   => chr(8250),
                oline    => chr(8254),
                frasl    => chr(8260),
                euro     => chr(8364),
                image    => chr(8465),
                weierp   => chr(8472),
                real     => chr(8476),
                trade    => chr(8482),
                alefsym  => chr(8501),
                larr     => chr(8592),
                uarr     => chr(8593),
                rarr     => chr(8594),
                darr     => chr(8595),
                harr     => chr(8596),
                crarr    => chr(8629),
                lArr     => chr(8656),
                uArr     => chr(8657),
                rArr     => chr(8658),
                dArr     => chr(8659),
                hArr     => chr(8660),
                forall   => chr(8704),
                part     => chr(8706),
                exist    => chr(8707),
                empty    => chr(8709),
                nabla    => chr(8711),
                isin     => chr(8712),
                notin    => chr(8713),
                ni       => chr(8715),
                prod     => chr(8719),
                sum      => chr(8721),
                minus    => chr(8722),
                lowast   => chr(8727),
                radic    => chr(8730),
                prop     => chr(8733),
                infin    => chr(8734),
                ang      => chr(8736),
                'and'    => chr(8743),
                'or'     => chr(8744),
                cap      => chr(8745),
                cup      => chr(8746),
                'int'    => chr(8747),
                there4   => chr(8756),
                sim      => chr(8764),
                cong     => chr(8773),
                asymp    => chr(8776),
                'ne'     => chr(8800),
                equiv    => chr(8801),
                'le'     => chr(8804),
                'ge'     => chr(8805),
                'sub'    => chr(8834),
                sup      => chr(8835),
                nsub     => chr(8836),
                sube     => chr(8838),
                supe     => chr(8839),
                oplus    => chr(8853),
                otimes   => chr(8855),
                perp     => chr(8869),
                sdot     => chr(8901),
                lceil    => chr(8968),
                rceil    => chr(8969),
                lfloor   => chr(8970),
                rfloor   => chr(8971),
                lang     => chr(9001),
                rang     => chr(9002),
                loz      => chr(9674),
                spades   => chr(9824),
                clubs    => chr(9827),
                hearts   => chr(9829),
                diams    => chr(9830),
                )
            : ()
            )
    );

    # encode html entities like "&#8211;"
    $Param{String} =~ s{
        (&\#(\d+);?)
    }
    {
        my $Chr = chr( $2 );
        if ( $Chr ) {
            $Chr;
        }
        else {
            $1;
        };
    }egx;

    # encode html entities like "&#3d;"
    $Param{String} =~ s{
        (&\#[xX]([0-9a-fA-F]+);?)
    }
    {
        my $ChrOrig = $1;
        my $Hex = hex( $2 );
        if ( $Hex ) {
            my $Chr = chr( $Hex );
            if ( $Chr ) {
                $Chr;
            }
            else {
                $ChrOrig;
            }
        }
        else {
            $ChrOrig;
        }
    }egx;

    # encode html entities like "&amp;"
    $Param{String} =~ s{
        (&(\w+);?)
    }
    {
        if ( $Entity{$2} ) {
            $Entity{$2};
        }
        else {
            $1;
        }
    }egx;

    # remove empty lines
    $Param{String} =~ s/^\s*\n\s*\n/\n/mg;

    # force line braking
    if ( length $Param{String} > 78 ) {
        $Param{String} =~ s/(.{4,78})(?:\s|\z)/$1\n/gm;
    }

    # add extracted links
    if ($LinkList) {
        $Param{String} .= "\n\n" . $LinkList;
    }

    return $Param{String};
}

=item ToHTML()

convert an ascii string to a html string

    my $Ascii = $HTML2AsciiObject->ToHTML( String => $String );

=cut

sub ToHTML {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(String)) {
        if ( !defined $Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # fix some bad stuff from opera and others
    $Param{String} =~ s/(\n\r|\r\r\n|\r\n)/\n/gs;

    $Param{String} =~ s/&/&amp;/g;
    $Param{String} =~ s/</&lt;/g;
    $Param{String} =~ s/>/&gt;/g;
    $Param{String} =~ s/"/&quot;/g;
    $Param{String} =~ s/(\n|\r)/<br\/>\n/g;
    $Param{String} =~ s/  /&nbsp;&nbsp;/g;

    return $Param{String};
}

=item DocumentComplete ()

check and e. g. add <html> and <body> tags to given html string

    my $HTMLDocument = $HTML2AsciiObject->DocumentComplete(
        String  => $String,
        Charset => $Charset,
    );

=cut

sub DocumentComplete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(String Charset)) {
        if ( !defined $Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    return $Param{String} if $Param{String} =~ /<html>/i;

    my $Css = $Self->{ConfigObject}->Get('Frontend::RichText::DefaultCSS')
        || 'font-size: 12px; font-family:Courier,monospace,fixed;';

    my $Body = '<html><head>';
    $Body .= '<meta http-equiv="Content-Type content=text/html; charset=' . $Param{Charset} . '"/>';
    $Body .= '</head><body style="' . $Css . '">' . $Param{String} . '</body></html>';
    return $Body;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see http://www.gnu.org/licenses/agpl.txt.

=head1 VERSION

$Revision: 1.10 $ $Date: 2009-07-15 20:03:48 $

=cut
