use 5.005;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'HTML::Stripper',
    VERSION_FROM => 'lib/HTML/Stripper.pm',
    PREREQ_PM    => {
        'HTML::Parser' => '3.33'
    }
);
