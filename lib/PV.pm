# -*-cperl-*-
#
# PerlVision -  Text-mode User Interface Widgets.
# Copyright (c) 1995-2000 Ashish Gulhati <hash@netropolis.org>
#
# All rights reserved. This code is free software; you can
# redistribute it and/or modify it under the same terms as Perl
# itself.
#
# $Id: PV.pm,v 1.5 2000/10/31 08:06:08 cvs Exp $

use 5.010;
use strict;
use warnings;

#----------
package PV;
#----------
use Curses;
our $VERSION = 1.503;

# Sets things up
sub init {    # void ()
  initscr();
  raw();
  noecho();
  eval { keypad( 1 ); };
  eval {
    start_color();
    init_pair( 1, COLOR_BLACK, COLOR_WHITE );
    init_pair( 2, COLOR_WHITE, COLOR_WHITE );
    init_pair( 3, COLOR_BLACK, COLOR_CYAN );
    init_pair( 4, COLOR_WHITE, COLOR_CYAN );
    init_pair( 5, COLOR_BLUE,  COLOR_WHITE );
    init_pair( 6, COLOR_WHITE, COLOR_BLUE );
    init_pair( 7, COLOR_BLUE,  COLOR_CYAN );
  };
  return;
} #/ sub init

sub done {    # void ()
  endwin();
  return;
}

# Draws your basic 3D box.
sub mybox {    # void ($x1, $y1, $x2, $y2, $style, $color, $window)
  my ( $x1, $y1, $x2, $y2, $style, $color, $window ) = @_;
  my $lines = $x2 - $x1;
  my $j;
  my ( $TOPL, $BOTR );
  if   ( $style ) { $TOPL = 1; $BOTR = 0 }
  else            { $TOPL = 0; $BOTR = 1 }
  move( $window, $y1, $x1 );
  attron( $window, COLOR_PAIR( 1 + $TOPL + $color * 2 ) );
  $TOPL ? attron( $window, A_BOLD ) : attroff( $window, A_BOLD );
  addch( $window, ACS_ULCORNER );
  hline( $window, ACS_HLINE, $lines - 1 );
  attron( $window, COLOR_PAIR( 1 + $BOTR + $color * 2 ) );
  $BOTR ? attron( $window, A_BOLD ) : attroff( $window, A_BOLD );
  move( $window, $y1, $x1 + $lines );
  addch( $window, ACS_URCORNER );
  move( $window, $y1 + 1, $x1 );
  attron( $window, COLOR_PAIR( 1 + $TOPL + $color * 2 ) );
  $TOPL ? attron( $window, A_BOLD ) : attroff( $window, A_BOLD );
  vline( $window, ACS_VLINE, $y2 - $y1 - 1 );
  move( $window, $y1 + 1, $x1 + $lines );
  attron( $window, COLOR_PAIR( 1 + $BOTR + $color * 2 ) );
  $BOTR ? attron( $window, A_BOLD ) : attroff( $window, A_BOLD );
  vline( $window, ACS_VLINE, $y2 - $y1 - 1 );
  move( $window, $y2, $x1 );
  attron( $window, COLOR_PAIR( 1 + $TOPL + $color * 2 ) );
  $TOPL ? attron( $window, A_BOLD ) : attroff( $window, A_BOLD );
  addch( $window, ACS_LLCORNER );
  attron( $window, COLOR_PAIR( 1 + $BOTR + $color * 2 ) );
  $BOTR ? attron( $window, A_BOLD ) : attroff( $window, A_BOLD );
  hline( $window, ACS_HLINE, $lines - 1 );
  move( $window, $y2, $x1 + $lines );
  addch( $window, ACS_LRCORNER );

  for ( $j = $y1 + 1 ; $j < $y2 ; $j++ ) {
    move( $window, $j, $x1 + 1 );
    addstr( $window, " " x ( $lines - 1 ) );
  }
  attroff( $window, A_BOLD );
  return;
} #/ sub mybox

# Gets a keystroke and returns a code
# and the key if it's printable.
sub getkey {    # $key, $keycode ()
  my $key = getch();
  my $keycode = 0;
  if ( $key =~ /^\d+$/ && $key >= 0x100 ) {
    if ( $key eq KEY_HOME ) {
      $keycode = 1;
    }
    elsif ( $key eq KEY_IC ) {
      $keycode = 2;
    }
    elsif ( $key eq KEY_DC ) {
      $keycode = 3;
    }
    elsif ( $key eq KEY_END ) {
      $keycode = 4;
    }
    elsif ( $key eq KEY_PPAGE ) {
      $keycode = 5;
    }
    elsif ( $key eq KEY_NPAGE ) {
      $keycode = 6;
    }
    elsif ( $key eq KEY_UP ) {
      $keycode = 7;
    }
    elsif ( $key eq KEY_DOWN ) {
      $keycode = 8;
    }
    elsif ( $key eq KEY_RIGHT ) {
      $keycode = 9;
    }
    elsif ( $key eq KEY_LEFT ) {
      $keycode = 10;
    }
    elsif ( $key eq KEY_BACKSPACE ) {
      $keycode = 11;
    }
    elsif ( keyname( $key ) eq 'ALT_X' ) {
      $keycode = 12;
    }
    elsif ( keyname( $key ) eq 'CTL_LEFT' ) {
      $keycode = 13;
    }
    elsif ( keyname( $key ) eq 'CTL_DEL' ) {
      $keycode = 14;
    }
    elsif ( keyname( $key ) eq 'CTL_HOME' ) {
      $keycode = 16;
    }
    elsif ( keyname( $key ) eq 'CTL_END' ) {
      $keycode = 17;
    }
    elsif ( $key eq KEY_F( 1 ) ) {
      $keycode = 18;
    }
    elsif ( $key eq KEY_F( 10 ) ) {
      $keycode = 19;
    }
    elsif ( keyname( $key ) eq 'CTL_RIGHT' ) {
      $keycode = 20;
    }
  } #/ if ( $key =~ /^\d+$/ &&...)
  elsif ( $key eq "\e" ) {
    $key = getch();
    if ( $key =~ /[WwBbFfIiQqVv<>DdXxHh]/ ) {    # Meta keys
      ( $key =~ /[Qq]/ ) && ( $keycode = 12 );   # M-q
      ( $key =~ /[Bb]/ ) && ( $keycode = 13 );   # M-b
      ( $key =~ /[Dd]/ ) && ( $keycode = 14 );   # M-d
      ( $key =~ /[Vv]/ ) && ( $keycode = 15 );   # M-v
      ( $key eq "<" )    && ( $keycode = 16 );   # M-<
      ( $key eq ">" )    && ( $keycode = 17 );   # M->
      ( $key =~ /[Hh]/ ) && ( $keycode = 18 );   # M-h
      ( $key =~ /[Xx]/ ) && ( $keycode = 19 );   # M-x
      ( $key =~ /[Ff]/ ) && ( $keycode = 20 );   # M-f
      ( $key =~ /[Ii]/ ) && ( $keycode = 21 );   # M-i
      ( $key =~ /[Ww]/ ) && ( $keycode = 22 );   # M-w
    } #/ if ( $key =~ /[WwBbFfIiQqVv<>DdXxHh]/)
    else {
      $keycode = 100;
    }
  } #/ if ( $key eq "\e" )
  elsif ( $key =~ /[A-Za-z0-9_ \t\n\r~\`!@#\$%^&*()\-+=\\|{}[\];:'"<>,.\/?]/ ) {
    $keycode = 200;
  }
  return ( $key, $keycode );
} #/ sub getkey

# Trivial static text class for dialog boxes
#------------------
package PV::Static;
#------------------
use strict;
use warnings;
use Curses;

use Class::Struct
  view => 'Curses::Window',
  text => '$',
  ax   => '$',
  ay   => '$',
  bx   => '$',
  by   => '$',
  ;

around: {    # $obj ($class, $atext, $x1, $y1, $x2, $y2)
  no warnings 'redefine';
  my $orig  = \&new; *new = sub {
  my $class = shift;
  my ( $atext, $x1, $y1, $x2, $y2 ) = @_;
  return $class->$orig(
    view => stdscr,
    text => $atext,
    ax   => $x1,
    ay   => $y1,
    bx   => $x2,
    by   => $y2,
  );
}}

sub place {    # void ($self)
  my $self = shift;
  my ( $x1, $y1, $x2, $y2 ) = ( $self->ax, $self->ay, $self->bx, $self->by );
  my @lines = split( "\n", $self->text );
  my $dx = $x2 - $x1;
  my $dy = $y2 - $y1;
  attron( $self->view, COLOR_PAIR( 3 ) );
  foreach ( @lines[ 0 .. $dy ] ) {
    $_ = '' unless defined;    # $_ //= '';
    move( $self->view, $y1, $x1 );
    addstr( $self->view, substr( $_, 0, $dx ) );
    $y1++;
  }
  return;
} #/ sub place

sub display {    # void ($self)
  my $self = shift;
  $self->place();
  refresh( $self->view );
  return;
}

#--------------------
package PV::Checkbox;
#--------------------
use strict;
use warnings;
use Curses;
use Class::Struct
  view  => 'Curses::Window',
  label => '$',
  x     => '$',
  y     => '$',
  mark  => '$',
  ;

# Creates a basic check box
around: {    # $obj ($class, $label, $x, $y, $sel)
  no warnings 'redefine';
  my $orig  = \&new; *new = sub {
  my $class = shift;
  my ( $label, $x, $y, $sel ) = @_;
  return $class->$orig(
    view  => stdscr, 
    label => $label,
    x     => $x, 
    y     => $y, 
    mark  => $sel,
  );
}}

sub place {    # void ($self)
  my $self = shift;
  move( $self->view, $self->y, $self->x );
  attron( $self->view, COLOR_PAIR( 4 ) );
  attron( $self->view, A_BOLD );
  addstr( $self->view, "[" );
  attroff( $self->view, A_BOLD );
  attron( $self->view, COLOR_PAIR( 3 ) );
  if ( $self->mark ) { addch( $self->view, ACS_RARROW ) }
  else               { addstr( $self->view, " " ) }
  attron( $self->view, COLOR_PAIR( 4 ) );
  attron( $self->view, A_BOLD );
  addstr( $self->view, "]" );
  attroff( $self->view, A_BOLD );
  attron( $self->view, COLOR_PAIR( 3 ) );
  addstr( $self->view, " " . $self->label );
  return;
} #/ sub place

sub display {    # void ($self)
  my $self = shift;
  $self->place();
  refresh( $self->view );
  return;
}

# Refreshes display of your check box
sub rfsh {    # void ($self)
  my $self = shift;
  move( $self->view, $self->y, $self->x + 1 );
  attron( $self->view, COLOR_PAIR( 3 ) );
  if ( $self->mark ) { addch( $self->view, ACS_RARROW ) }
  else               { addstr( $self->view, " " ) }
  move( $self->view, $self->y, $self->x + 1 );
  refresh( $self->view );
  return;
} #/ sub rfsh

# Makes checkbox active
sub activate {    # $cmd ($self)
  my $self = shift;
  $self->rfsh;
  # refresh_cursor();

  while ( my @key = PV::getkey() ) {

    switch: {
      case: $key[1] == 7 and do {    # UpArrow
        return 1;
      };
      case: $key[1] == 8 and do {    # DnArrow
        return 2;
      };
      case: $key[1] == 9 and do {    # RightArrow
        return 3;
      };
      case: $key[1] == 10 and do {    # LeftArrow
        return 4;
      };
      case: $key[1] == 18 and do {    # Help
        return 5;
      };
      case: $key[1] == 19 and do {    # Menu
        return 6;
      };
      case: ( $key[1] == 200 ) && ( $key[0] eq "\t" ) and do {
        return 7;
      };
      case: ( $key[1] == 200 ) && ( $key[0] eq ' ' ) and do {
        $self->select;
        last;
      };
    } #/ switch:
    $self->rfsh;
    # refresh_cursor();

  } #/ while ( @key = PV::getkey...)
} #/ sub activate

# Toggles checkbox status
sub select {    # void ($self)
  my $self = shift;
  $self->mark( $self->mark ? 0 : 1 );
  return;
}

# Returns status of checkbox
sub stat {    # $enbld ($self)
  my $self = shift;
  return $self->state;
}

#-----------------
package PV::Radio;
#-----------------
use strict;
use warnings;
use Curses;
use parent -norequire, qw(PV::Checkbox);

# Creates your basic radio button
sub new {    # $obj ($class, $label, $x, $y, $sel)
  my $class = shift;
  my ( $label, $x, $y, $sel ) = @_;
  my $self = $class->SUPER::new( $label, $x, $y, $sel );
  push @$self, my $group;
  return bless $self, $class;
}

# Displays a radio button
sub place {    # void ($self)
  my $self = shift;
  move( $self->view, $self->y, $self->x );
  attron( $self->view, COLOR_PAIR( 4 ) );
  attron( $self->view, A_BOLD );
  addstr( $self->view, "(" );
  attroff( $self->view, A_BOLD );
  attron( $self->view, COLOR_PAIR( 3 ) );
  if ( $self->mark ) { addch( $self->view, ACS_DIAMOND ) }
  else               { addstr( $self->view, " " ) }
  attron( $self->view, COLOR_PAIR( 4 ) );
  attron( $self->view, A_BOLD );
  addstr( $self->view, ")" );
  attroff( $self->view, A_BOLD );
  attron( $self->view, COLOR_PAIR( 3 ) );
  addstr( $self->view, " " . $self->label );
  return;
} #/ sub place

sub display {    # void ($self)
  my $self = shift;
  $self->place();
  refresh( $self->view );
  return;
}

# Refreshes display of your check box
sub rfsh {    # void ($self)
  my $self = shift;
  move( $self->view, $self->y, $self->x + 1 );
  attron( $self->view, COLOR_PAIR( 3 ) );
  if ( $self->mark ) { addch( $self->view, ACS_DIAMOND ) }
  else               { addstr( $self->view, " " ) }
  move( $self->view, $self->y, $self->x + 1 );
  refresh( $self->view );
  return;
} #/ sub rfsh

# Gets the associated group.
# Puts the button in a group, should not be called from outside
sub group {    # $group ($self, | $group)
  my $self = shift;
  $self->[6] = shift if @_;
  return $self->[6];
}

# Turn radio button on
sub select {    # void ($self)
  my $self = shift;
  unless ( $self->mark ) {
    $self->group->blank if $self->group;
    $self->mark( 1 );
    $self->group->rfsh;
  }
  return;
}

# Turn radio button off
sub unselect {    # void ($self)
  my $self = shift;
  $self->mark( 0 );
  return;
}

#------------------
package PV::RadioG;
#------------------
use strict;
use warnings;
use Curses;

# Creates your basic radio button group
#   $obj = PV::RadioG->new($rb1, $rb2, $rb3, ...);
# where $rbN is of class 'PV::Radio'
sub new {    # $obj ($class, @rb)
  my $class = shift;
  my @items = @_;
  my $self  = [ @items ];
  foreach my $item ( @$self ) {
    $item->group( $self );
  }
  return bless $self, $class;
} #/ sub new

sub place {    # void ($self)
  my $self = shift;
  foreach my $item ( @$self ) {
    $item->display;
  }
  return;
}

sub display {    # void ($self)
  my $self = shift;
  $self->place();
  return;
}

sub rfsh {    # void ($self)
  my $self = shift;
  foreach my $item ( @$self ) {
    $item->rfsh;
  }
  return;
}

# Unchecks all buttons in the group
sub blank {    # void ($self)
  my $self = shift;
  foreach my $item ( @$self ) {
    $item->unselect;
  }
  return;
}

# Returns label of selected radio button
sub stat {    # $label ($self)
  my $self = shift;
  foreach my $item ( @$self ) {
    return $item->label if $item->stat;
  }
  return '';
}

#----------------------
package PV::Pushbutton;
#----------------------
use strict;
use warnings;
use Curses;
use Class::Struct
  view  => 'Curses::Window',
  label => '$',
  x     => '$',
  y     => '$',
  ;

# Creates a basic pushbutton
around: {    # $obj ($class, $label, $x, $y);
  no warnings 'redefine';
  my $orig  = \&new; *new = sub {
  my $class = shift;
  my ( $label, $x, $y ) = @_;
  return $class->$orig(
    view  => stdscr,
    label => $label,
    x     => $x,
    y     => $y,
  );
}}

sub place {    # void ($self)
  my $self = shift;
  PV::mybox(
    $self->x,
    $self->y, 
    $self->x + length( $self->label ) + 3,
    $self->y + 2, 
    1, 0, $self->view
  );
  attron( $self->view, COLOR_PAIR( 1 ) );
  move( $self->view, $self->y + 1, $self->x + 2 );
  addstr( $self->view, $self->label );
  return;
} #/ sub place

sub display {    # void ($self)
  my $self = shift;
  $self->place();
  refresh( $self->view );
  return;
}

sub press {    # void ($self)
  my $self = shift;
  PV::mybox(
    $self->x,
    $self->y,
    $self->x + length( $self->label ) + 3,
    $self->y + 2, 
    0, 0, $self->view
  );
  attron( $self->view, COLOR_PAIR( 1 ) );
  move( $self->view, $self->y + 1, $self->x + 2 );
  addstr( $self->view, $self->label );
  refresh( $self->view );
  return;
} #/ sub press

sub active {    # void ($self)
  my $self = shift;
  attron( $self->view, COLOR_PAIR( 6 ) );
  attron( $self->view, A_BOLD );
  move( $self->view, $self->y + 1, $self->x + 2 );
  addstr( $self->view, $self->label );
  attroff( $self->view, A_BOLD );
  refresh( $self->view );
  return;
} #/ sub active

sub activate {    # $cmd ($self)
  my $self = shift;
  $self->active;
  while ( my @key = PV::getkey() ) {

    switch: {
      case: $key[1] == 7 and do {    # UpArrow
        $self->display;
        return 1;
      };
      case: $key[1] == 8 and do {    # DnArrow
        $self->display;
        return 2;
      };
      case: $key[1] == 9 and do {    # RightArrow
        $self->display;
        return 3;
      };
      case: $key[1] == 10 and do {    # LeftArrow
        $self->display;
        return 4;
      };
      case: $key[1] == 18 and do {    # Help
        $self->display;
        return 5;
      };
      case: $key[1] == 19 and do {    # Menu
        $self->display;
        return 6;
      };
      case: ( $key[1] == 200 ) && ( $key[0] eq "\t" ) and do {
        $self->display;
        return 7;
      };
      case: ( $key[1] == 200 ) && ( $key[0] eq ' ' || $key[0] eq "\cM" ) and do {
        $self->press;
        return 8;
      };
    } #/ switch:
  } #/ while ( @key = PV::getkey...)
} #/ sub activate

#----------------------
package PV::Cutebutton;
#----------------------
use strict;
use warnings;
use Curses;
use parent -norequire, qw(PV::Pushbutton);

# A smaller, cuter pushbutton
sub new {    # $obj ($class, $label, $x, $y);
  my $class = shift;
  my ( $label, $x, $y ) = @_;
  my $self = $class->SUPER::new( $label, $x, $y );
  return bless $self, $class;
}

sub place {    # void ($self)
  my $self = shift;
  attron( $self->view, COLOR_PAIR( 7 ) );
  addstr( $self->view, $self->y, $self->x, "  " . $self->label . " " );
  attron( $self->view, COLOR_PAIR( 3 ) );
  addch( $self->view, ACS_VLINE );
  attron( $self->view, COLOR_PAIR( 4 ) );
  attron( $self->view, A_BOLD );
  move( $self->view, $self->y + 1, $self->x );
  addch( $self->view, ACS_LLCORNER );
  attroff( $self->view, A_BOLD );
  attron( $self->view, COLOR_PAIR( 3 ) );
  hline( $self->view, ACS_HLINE, length( $self->label ) + 2 );
  addch(
    $self->view, $self->y + 1, $self->x + length( $self->label ) + 3,
    ACS_LRCORNER
  );
  return;
} #/ sub place

sub press {    # void ($self)
  my $self = shift;
  attron( $self->view, COLOR_PAIR( 3 ) );
  addch( $self->view, $self->y, $self->x, ACS_ULCORNER );
  hline( $self->view, ACS_HLINE, length( $self->label ) + 2 );
  attron( $self->view, COLOR_PAIR( 4 ) );
  attron( $self->view, A_BOLD );
  addch(
    $self->view, $self->y, $self->x + length( $self->label ) + 3,
    ACS_URCORNER
  );
  move( $self->view, $self->y + 1, $self->x );
  attron( $self->view, COLOR_PAIR( 3 ) );
  attroff( $self->view, A_BOLD );
  addch( $self->view, ACS_VLINE );
  attron( $self->view, COLOR_PAIR( 7 ) );
  addstr( $self->view, " " . $self->label . "  " );
  refresh( $self->view );
  return;
} #/ sub press

sub active {    # void ($self)
  my $self = shift;
  attron( $self->view, COLOR_PAIR( 5 ) );
  attron( $self->view, A_BOLD );
  attron( $self->view, A_REVERSE );
  move( $self->view, $self->y, $self->x + 2 );
  addstr( $self->view, $self->label );
  attroff( $self->view, A_BOLD );
  attroff( $self->view, A_REVERSE );
  refresh( $self->view );
  return;
} #/ sub active

#-----------------------
package PV::Plainbutton;
#-----------------------
use strict;
use warnings;
use Curses;
use parent -norequire, qw(PV::Pushbutton);

# A minimal pushbutton
sub new {    # $obj ($class, $label, $x, $y);
  my $class = shift;
  my ( $label, $x, $y ) = @_;
  my $self = $class->SUPER::new( $label, $x, $y );
  return bless $self, $class;
}

sub place {    # void ($self)
  my $self = shift;
  attron( $self->view, COLOR_PAIR( 4 ) );
  attron( $self->view, A_BOLD );
  move( $self->view, $self->y, $self->x );
  addstr( $self->view, $self->label );
  attroff( $self->view, A_BOLD );
  return;
}

sub press {    # void ($self)
  return;
}

sub active {    # void ($self)
  my $self = shift;
  attron( $self->view, COLOR_PAIR( 5 ) );
  attron( $self->view, A_BOLD );
  attron( $self->view, A_REVERSE );
  move( $self->view, $self->y, $self->x );
  addstr( $self->view, $self->label );
  refresh( $self->view );
  attroff( $self->view, A_BOLD );
  attroff( $self->view, A_REVERSE );
  return;
} #/ sub active

#-----------------------
package PV::_::SListbox;
#-----------------------
use strict;
use warnings;
use Curses;
use Class::Struct
  view  => 'Curses::Window',
  label => '$',
  idx   => '$',
  ax    => '$',
  ay    => '$',
  bx    => '$',
  by    => '$',
  ;

# Creates a superclass list box
# $obj = PV::_::SListbox->new($label, $x1, $y1, $x2, $y2, %list);
# where %list is ( $txt1 => $sel1, $txt2 => $sel2, ... )
# Do not use from outside
around: {    # obj ($class, $label, $x1, $y1, $x2, $y2, %list)
  no warnings 'redefine';
  my $orig  = \&new; *new = sub {
  my $class = shift;
  my ( $label, $x1, $y1, $x2, $y2, @list ) = @_;
  my $self = $class->$orig(
    view  => stdscr,
    label => $label,
    idx   => 0,
    ax    => $x1,
    ay    => $y1,
    bx    => $x2,
    by    => $y2,
  );
  push @$self, @list;
  return $self;
}}

sub place {    # void ($self, | $i)
  my $self = shift;
  my $i    = shift || 0;
  my ( $x1, $y1, $x2, $y2 ) = ( $self->ax, $self->ay, $self->bx, $self->by );
  $self->draw_border;
  $i *= 2;
  $x1++;
  $y1++;
  while ( ( $y1 < $y2 ) && ( 7 + $i < $#$self ) ) {
    my $enbld = 8 + $i;
    if ( $self->[ $enbld ] ) { $self->selected( $y1, $i ) }
    else                     { $self->unselected( $y1, $i ) }
    $y1++;
    $i += 2;
  }
  return;
} #/ sub place

sub display {    # void ($self)
  my $self = shift;
  $self->place();
  refresh( $self->view );
  return;
}

sub rfsh {    # void ($self, $i)
  my $self  = shift;
  my ( $i ) = @_;
  my ( $x1, $y1, $x2, $y2 ) = ( $self->ax, $self->ay, $self->bx, $self->by );
  if ( $i != $self->idx ) {
    $self->idx( $i );
    $i *= 2;
    $x1++;
    $y1++;
    while ( ( $y1 < $y2 ) && ( 7 + $i < $#$self ) ) {
      my $enbld = 8 + $i;
      if ( $self->[ $enbld ] ) { $self->selected( $y1, $i ) }
      else                     { $self->unselected( $y1, $i ) }
      $y1++;
      $i += 2;
    }
  } #/ unless ( $i == $self->idx )
  refresh( $self->view );
  return;
} #/ sub rfsh

sub unhighlight {    # void ($self, $ypos, $i)
  my $self = shift;
  my ( $ypos, $i ) = @_;
  my $enbld = 8 + $i;
  if ( $self->[ $enbld ] ) { $self->selected( $ypos, $i ) }
  else                     { $self->unselected( $ypos, $i ) }
  refresh( $self->view );
  return;
}

sub highlight {    # void ($self, $ypos, $i)
  my $self = shift;
  my ( $ypos, $i ) = @_;
  my $txt = 7 + $i;
  my ( $x1, $x2 ) = ( $self->ax, $self->bx );
  $x1++;
  attron( $self->view, COLOR_PAIR( 5 ) );
  attron( $self->view, A_BOLD );
  attron( $self->view, A_REVERSE );
  move( $self->view, $ypos, $x1 + 1 );
  addstr(
    $self->view,
    substr( $self->[$txt], 0, $x2 - $x1 - 2 )
      . " " x
      ( $x2 - $x1 - 2 - length( substr( $self->[$txt], 0, $x2 - $x1 - 2 ) ) )
  );
  attroff( $self->view, A_BOLD );
  attroff( $self->view, A_REVERSE );
  refresh( $self->view );
  return;
} #/ sub highlight

sub selected {    # void ($self, $ypos, $i)
  my $self = shift;
  my ( $ypos, $i ) = @_;
  $self->unselected( $ypos, $i );
  return;
}

sub reset {    # void ($self)
  my $self = shift;
  for ( my $i = 7 ; $i < @$self ; $i += 2 ) {
    my $enbld = $i + 1;
    $self->[ $enbld ] = 0;
  }
  $self->rfsh( 0 );
  return;
}

sub stat {    # @list ($self)
  my $self = shift;
  my @returnlist = ();
  for ( my $i = 7 ; $i < @$self ; $i += 2 ) {
    my $txt = $i;
    my $enbld = $i + 1;
    push @returnlist, $self->[$txt] if $self->[$enbld];
  }
  $self->reset;
  return @returnlist;
} #/ sub stat

sub done {    # void ($self, $i)
  my $self = shift;
  my ( $i ) = @_;
  my $enbld = 8 + $i * 2;
  $self->[ $enbld ] = 1;
  $self->rfsh( 0 );
  return;
}

sub deactivate {    # void ($self)
  my $self = shift;
  $self->reset();
  return;
}

sub unselected {    # void ($self, $ypos, $i)
  my $self = shift;
  my ( $ypos, $i ) = @_;
  my $txt = 7 + $i;
  my ( $x1, $x2 ) = ( $self->ax, $self->bx );
  $x1++;
  attron( $self->view, COLOR_PAIR( 3 ) );
  move( $self->view, $ypos, $x1 + 1 );
  addstr(
    $self->view,
    substr( $self->[$txt], 0, $x2 - $x1 - 2 )
      . " " x
      ( $x2 - $x1 - 2 - length( substr( $self->[$txt], 0, $x2 - $x1 - 2 ) ) )
  );
  return;
} #/ sub unselected

sub activate {    # $cmd ($self)
  my $self = shift;
  my ( $x1, $y1, $x2, $y2 ) = ( $self->ax, $self->ay, $self->bx, $self->by );
  my $i = 0;
  $x1++;
  $y1++;
  my $ypos = $y1;
  $self->rfsh( $i );
  $self->highlight( $y1, $i * 2 );

  while ( my @key = PV::getkey() ) {

    switch: {
      case: $key[1] == 18 and do {    # Help
        $self->unhighlight( $ypos, $i * 2 );
        $self->deactivate();
        return 5;
      };
      case: $key[1] == 19 and do {    # Menu
        $self->unhighlight( $ypos, $i * 2 );
        $self->deactivate();
        return 6;
      };
      case: $key[1] == 9 and do {     # RightArrow
        $self->unhighlight( $ypos, $i * 2 );
        $self->deactivate();
        return 3;
      };
      case: $key[1] == 10 and do {    # LeftArrow
        $self->unhighlight( $ypos, $i * 2 );
        $self->deactivate();
        return 4;
      };
      case: ( $key[1] == 200 ) && ( $key[0] eq "\t" ) and do {
        $self->unhighlight( $ypos, $i * 2 );
        $self->deactivate();
        return 7;
      };
      case: ( $key[1] == 200 ) && ( $key[0] eq "\cM" ) and do {
        $self->unhighlight( $ypos, $i * 2 );
        $self->done( $i );
        return 8;
      };
      case: ( $key[1] == 200 ) && ( $key[0] eq " " ) and do {
        $self->select( $i );
        $self->highlight( $ypos, $i * 2 );
        last;
      };
      case: ( $key[1] == 7 ) && ( $i != 0 ) and do {    # Up
        if ( $ypos != $y1 ) {
          $self->unhighlight( $ypos, $i * 2 );
          $ypos--;
        }
        $i--;
        $self->rfsh( $i - $ypos + $y1 );
        $self->highlight( $ypos, $i * 2 );
        last;
      };
      case: ( $key[1] == 8 ) && ( ( $i * 2 + 9 ) < $#$self ) and do {    # Down
        if ( $ypos != $y2 - 1 ) {
          $self->unhighlight( $ypos, $i * 2 );
          $ypos++;
        }
        $i++;
        $self->rfsh( $i - $ypos + $y1 );
        $self->highlight( $ypos, $i * 2 );
        last;
      };
    } #/ switch:
  } #/ while ( @key = PV::getkey...)
} #/ sub activate

sub draw_border {    # void ($self)
  my $self = shift;
  PV::mybox( $self->ax, $self->ay, $self->bx, $self->by, 0, 1, $self->view );
  attron( $self->view, COLOR_PAIR( 4 ) );
  attron( $self->view, A_BOLD );
  move( $self->view, $self->ay, $self->ax );
  addstr( $self->view, $self->label );
  attroff( $self->view, A_BOLD );
  return;
} #/ sub draw_border

sub select {    # void ($self, $i)
  return;
}

#-------------------
package PV::Listbox;
#-------------------
use strict;
use warnings;
use Curses;
use parent -norequire, qw(PV::_::SListbox);

# Basic single selection listbox
# $obj = PV::Listbox->new($label, $x1, $y1, $x2, $y2, %list);
# where %list is ($txt1 => $sel1, $txt2 => $sel2, ...)
sub new {    # $obj ($class, $label, $x1, $y1, $x2, $y2, %list)
  my $class = shift;
  my ( $label, $x1, $y1, $x2, $y2, @list ) = @_;
  my $self = $class->SUPER::new( $label, $x1, $y1, $x2, $y2, @list );
  return bless $self, $class;
}

#--------------------
package PV::Mlistbox;
#--------------------
use strict;
use warnings;
use Curses;
use parent -norequire, qw(PV::_::SListbox);

# A multiple selection listbox
# $obj = PV::Mlistbox->new($label, $x1, $y1, $x2, $y2, %list);
# where %list is ($txt1 => $sel1, $txt2 => $sel2, ...)
sub new {    # $obj ($class, $label, $x1, $y1, $x2, $y2, %list)
  my $class = shift;
  my ( $label, $x1, $y1, $x2, $y2, @list ) = @_;
  my $self = $class->SUPER::new( $label, $x1, $y1, $x2, $y2, @list );
  return bless $self, $class;
}

sub select {    # void ($self, $i)
  my $self = shift;
  my ( $i ) = @_;
  my $enbld = 8 + $i * 2;
  $self->[ $enbld ] = $self->[ $enbld ] ? 0 : 1;
  return;
} #/ sub select

sub selected {    # void ($self, $ypos, $i)
  my $self = shift;
  my ( $ypos, $i ) = @_;
  my $txt = 7 + $i;
  my ( $x1, $x2 ) = ( $self->ax, $self->bx );
  $x1++;
  attron( $self->view, COLOR_PAIR( 4 ) );
  attron( $self->view, A_BOLD );
  move( $self->view, $ypos, $x1 + 1 );
  addstr(
    $self->view,
    substr( $self->[$txt], 0, $x2 - $x1 - 2 )
      . " " x
      ( $x2 - $x1 - 2 - length( substr( $self->[$txt], 0, $x2 - $x1 - 2 ) ) )
  );
  attroff( $self->view, A_BOLD );
  return;
} #/ sub selected

sub highlight {    # void ($self, $ypos, $i)
  my $self = shift;
  my ( $ypos, $i ) = @_;
  my $txt = 7 + $i;
  my $enbld = 8 + $i;
  my ( $x1, $x2 ) = ( $self->ax, $self->bx );
  $x1++;
  attron( $self->view, COLOR_PAIR( 5 ) );
  if ( $self->[$enbld] ) { attron( $self->view, A_BOLD ) }
  attron( $self->view, A_REVERSE );
  move( $self->view, $ypos, $x1 + 1 );
  addstr(
    $self->view,
    substr( $self->[$txt], 0, $x2 - $x1 - 2 )
      . " " x
      ( $x2 - $x1 - 2 - length( substr( $self->[$txt], 0, $x2 - $x1 - 2 ) ) )
  );
  attroff( $self->view, A_BOLD );
  attroff( $self->view, A_REVERSE );
  refresh( $self->view );
  return;
} #/ sub highlight

sub deactivate {    # void ($self)
  my $self = shift;
  $self->rfsh();
  return;
}

sub done {    # void ($self)
  my $self = shift;
  $self->rfsh();
  return;
}

#-----------------------
package PV::_::Pulldown;
#-----------------------
use strict;
use warnings;
use Curses;
use parent -norequire, qw(PV::_::SListbox);

# A pulldown menu box. Used by PV::Menubar
# Don't use from outside
sub new {    # $obj ($class, $label, $x1, $y1, $x2, $y2, %list)
  my $class = shift;
  my ( $label, $x1, $y1, $x2, $y2, @list ) = @_;
  my $self = $class->SUPER::new( $label, $x1, $y1, $x2, $y2, @list );
  return bless $self, $class;
}

sub draw_border {    # void ($self)
  my $self = shift;
  PV::mybox( $self->ax, $self->ay, $self->bx, $self->by, 1, 0, $self->view );
  move( $self->view, $self->ay, $self->ax );
  attron( $self->view, COLOR_PAIR( 2 ) );
  attron( $self->view, A_BOLD );
  addch( $self->view, ( $self->[$#$self] == 1 ) ? ACS_VLINE : ACS_URCORNER );
  attroff( $self->view, A_BOLD );
  attron( $self->view, COLOR_PAIR( 1 ) );
  addstr( $self->view, " " x ( $self->bx - $self->ax - 1 ) );
  move( $self->view, $self->ay, $self->bx );
  addch( $self->view, ACS_ULCORNER );
  return;
} #/ sub draw_border

sub unselected {    # void ($self, $ypos, $i)
  my $self = shift;
  my ( $ypos, $i ) = @_;
  my $txt = 7 + $i;
  my ( $x1, $x2 ) = ( $self->ax, $self->bx );
  $x1++;
  attron( $self->view, COLOR_PAIR( 5 ) );
  move( $self->view, $ypos, $x1 + 1 );
  addstr(
    $self->view,
    substr( $self->[$txt], 0, $x2 - $x1 - 2 )
      . " " x
      ( $x2 - $x1 - 2 - length( substr( $self->[$txt], 0, $x2 - $x1 - 2 ) ) )
  );
  return;
} #/ sub unselected

sub activate {    # $cmd, $enbld ($self)
  my $self = shift;
  touchwin( $self->view );
  $self->display();
  my $ret = $self->SUPER::activate();
  touchwin( stdscr );
  refresh( stdscr );
  return ( $ret, $self->stat() );
}

#-------------------
package PV::Menubar;
#-------------------
use strict;
use warnings;
use Curses;

# A menu bar with pulldowns
# $obj = PV::Menubar->new($label, $width, $height, %list);
# where %list is ( $txt1 => 0, $txt2 => 0, ...)
sub new {    # $obj ($class, $label, $width, $height, %list)
  my $class = shift;
  my ( $label, $width, $height, @list ) = @_;
  my $pulldown = PV::_::Pulldown->new( $label, 0, 0, $width, $height, @list, 1 );
  my $startoff = 3;
  my $panel    = newwin( $height + 1, $width + 1, 2, $startoff - 2 );
  $pulldown->view( $panel );
  return bless [ $pulldown, $startoff ], $class;
}

# Add a pulldown to the menubar
# $obj->add($label, $width, $height, %list);
# where %list is ( $txt1 => 0, $txt2 => 0, ...)
sub add {    # void ($self, $label, $width, $height, %list)
  my $self = shift;
  my ( $label, $width, $height, @list ) = @_;
  my $pulldown = PV::_::Pulldown->new( $label, 0, 0, $width, $height, @list, 0 );
  my $startoff = $self->[$#$self] + length( $self->[ $#$self - 1 ]->label ) + 4;
  my $panel    = newwin( $height + 1, $width + 1, 2, $startoff - 2 );
  $pulldown->view( $panel );
  push @$self, ( $pulldown, $startoff );
  return;
} #/ sub add

sub highlight {    # void ($self, $i)
  my $self = shift;
  my ( $i ) = @_;
  my $txt = $i * 2;
  my $enbld = $i * 2 + 1;
  move( 1, $self->[ $enbld ] );
  attron( COLOR_PAIR( 7 ) );
  attron( A_BOLD );
  attron( A_REVERSE );
  addstr( $self->[ $txt ]->label );
  attroff( A_BOLD );
  attroff( A_REVERSE );
  refresh();
  return;
} #/ sub highlight

sub unhighlight {    # void ($self, $i)
  my $self = shift;
  my ( $i ) = @_;
  my $txt = $i * 2;
  my $enbld = $i * 2 + 1;
  move( 1, $self->[ $enbld ] );
  attron( COLOR_PAIR( 1 ) );
  addstr( $self->[ $txt ]->label );
  refresh();
  return;
}

sub activate {    # $cmd, | $enbld ($self)
  my $self = shift;
  my $i = 0;
  my @ret;
  $self->highlight( $i );
  while ( my @key = PV::getkey() ) {

    switch: {
      case: $key[1] == 18 and do {    # Help
        $self->unhighlight( $i );
        return 5;
      };
      case: $key[1] == 9 and do {     # RightArrow
        $self->[ $i * 2 ]->reset();
        $self->unhighlight( $i );
        $i = ( $i * 2 + 1 == $#$self ) ? 0 : $i + 1;
        $self->highlight( $i );
        last;
      };
      case: $key[1] == 10 and do {    # LeftArrow
        $self->[ $i * 2 ]->reset();
        $self->unhighlight( $i );
        $i = $i == 0 ? ( $#$self - 1 ) / 2 : $i - 1;
        $self->highlight( $i );
        last;
      };
      case: ( $key[1] == 200 ) && ( $key[0] eq "\t" ) and do {
        $self->unhighlight( $i );
        return 7;
      };
      case: ( ( $key[1] == 200 ) && ( $key[0] eq "\cM" ) ) || ( $key[1] == 8 )
      and do {
        while ( @ret = ( $self->[ $i * 2 ]->activate() ) ) {
          if ( $ret[0] == 3 ) {
            $self->[ $i * 2 ]->reset();
            $self->unhighlight( $i );
            $i = ( ( $i * 2 + 1 == $#$self ) ? 0 : $i + 1 );
            $self->highlight( $i );
          }
          elsif ( $ret[0] == 4 ) {
            $self->[ $i * 2 ]->reset();
            $self->unhighlight( $i );
            $i = ( $i == 0 ? ( $#$self - 1 ) / 2 : $i - 1 );
            $self->highlight( $i );
          }
          else {
            last;
          }
        } #/ while ( @ret = ( $self->[...]))
        refresh();
        if ( $ret[0] == 5 ) {
          $self->unhighlight( $i );
          return 5;
        }
        elsif ( $ret[0] == 8 ) {
          $self->unhighlight( $i );
          return ( 8, $self->[ $i * 2 ]->label . ":" . $ret[1] );
        }
        last;
      } #/ case: do
    } #/ switch:
  } #/ while ( @key = PV::getkey...)
} #/ sub activate

sub place {    # void ($self)
  my $self = shift;
  PV::mybox( 1, 0, 78, 2, 1, 0, stdscr );
  for ( my $i = 0 ; $i < @$self ; $i += 2 ) {
    my $pulldown = $i;
    my $xpos     = $i + 1;
    move( 1, $self->[$xpos] );
    addstr( $self->[$pulldown]->label );
  }
  return;
}

sub display {    # void ($self)
  my $self = shift;
  $self->place();
  refresh();
  return;
}

#----------------------
package PV::Entryfield;
#----------------------
use strict;
use warnings;
use Curses;
use Class::Struct
  view  => 'Curses::Window',
  x     => '$',
  y     => '$',
  len   => '$',
  max   => '$',
  label => '$',
  value => '$',
  ;

# Creates your basic text entry field
# $obj = PV::Entryfield->new($x, $y, $len, $max, $label, $value);
around: {    # $obj ($class, $x, $y, $len, $max, $label, $value)
  no warnings 'redefine';
  my $orig  = \&new; *new = sub {
  my $class = shift;
  my ( $x, $y, $len, $max, $label, $value ) = @_;
  $value = '' unless defined $value;    # $value //= '';
  return $class->$orig(
    view  => stdscr,
    x     => $x,
    y     => $y,
    len   => $len,
    max   => $max,
    label => $label,
    value => $value,
  );
}}

sub place {    # void ($self, | $start)
  my $self  = shift;
  my $start = shift || 0;
  my $len   = $self->len;
  my $value = $self->value;
  move( $self->view, $self->y, $self->x );
  attron( $self->view, COLOR_PAIR( 3 ) );
  addstr( $self->view, $self->label . " " );
  attron( $self->view, COLOR_PAIR( 6 ) );
  attron( $self->view, A_BOLD );
  addstr( $self->view, " " );
  addstr( $self->view, substr( $value, $start, $len ) );
  addstr( $self->view,
    "." x ( $len - length( substr( $value, $start, $len ) ) ) );
  addstr( $self->view, " " );
  attroff( $self->view, A_BOLD );
  return;
} #/ sub place

sub display {    # void ($self)
  my $self = shift;
  $self->place();
  refresh( $self->view );
  return;
}

sub rfsh {    # void ($self, $start, $i)
  my $self  = shift;
  my $start = shift;
  my $i     = shift;
  my $len   = $self->len;
  my $value = $self->value;
  if ( $self->max == $start ) {
    move( $self->view, $self->y,
      $self->x + length( $self->label ) + 2 + $i - $start );
    attron( $self->view, COLOR_PAIR( 6 ) );
    attron( $self->view, A_BOLD );
    addstr( $self->view, substr( $value, $i, $len - ( $i - $start ) ) );
    addstr(
      $self->view,
      "." x ( $len - ( $i - $start ) - length( substr( $value, $i, $len ) ) )
    );
    attroff( $self->view, A_BOLD );
  } #/ if ( $self->max == $start)
  else {
    $self->max( $start );
    move( $self->view, $self->y, $self->x + length( $self->label ) + 2 );
    attron( $self->view, COLOR_PAIR( 6 ) );
    attron( $self->view, A_BOLD );
    addstr( $self->view, substr( $value, $start, $len ) );
    addstr( $self->view,
      "." x ( $len - length( substr( $value, $start, $len ) ) ) );
    attroff( $self->view, A_BOLD );
  } #/ else [ if ( $self->max == $start)]
  return;
} #/ sub rfsh

# Makes entryfield active
sub activate {    # $cmd ($self)
  my $self        = shift;
  my $OVSTRK_MODE = 0;
  my ( $x, $y, $len ) = ( $self->x, $self->y, $self->len );
  my $i = 0;
  $x += length( $self->label ) + 2;
  my $start     = 0;
  my $savestart = 0;
  my $jump      = ( $len % 2 ) ? ( $len + 1 ) / 2 : $len / 2;
  $self->rfsh( $start, $i );
  move( $self->view, $y, $x );
  refresh( $self->view );

  while ( my @key = PV::getkey() ) {

    switch: {
      case: $key[1] == 7 and do {    # UpArrow
        $self->rfsh( 0, 0 );
        refresh( $self->view );
        return 1;
      };
      case: $key[1] == 8 and do {    # DnArrow
        $self->rfsh( 0, 0 );
        refresh( $self->view );
        return 2;
      };
      case: $key[1] == 18 and do {    # Help
        $self->rfsh( 0, 0 );
        refresh( $self->view );
        return 5;
      };
      case: $key[1] == 19 and do {    # Menu
        $self->rfsh( 0, 0 );
        refresh( $self->view );
        return 6;
      };
      case: $key[1] == 11 and do {    # Backspace
        if ( $i ) {
          $i--;
          substr( $self->value, $i, 1 ) = "";
          $start -= $jump if $i < $start;
          $start = 0      if $start < 0;
          $self->rfsh( $start, $i );
          move( $self->view, $y, $x + $i - $start );
          refresh( $self->view );
        }
        last;
      };
      case: $key[1] == 200 and do {
        if ( $key[0] =~ /[\n\r\t\f]/ ) {
          switch: {
            case: $key[0] eq "\t" and do {
              $self->rfsh( 0, 0 );
              refresh( $self->view );
              return 7;
            };
            case: ( $key[0] eq "\n" ) || ( $key[0] eq "\r" ) and do {
              $self->rfsh( 0, 0 );
              refresh( $self->view );
              return 8;
            };
            case: $key[0] eq "\f" and do {
              last;
            };
          }
        } #/ if ( $key[0] =~ /[\n\r\t\f]/)
        else {
          substr( $self->[6], $i, $OVSTRK_MODE ) = $key[0];
          $start += $jump if $i - $start >= $len;
          $self->rfsh( $start, $i );
          $i++;
          move( $self->view, $y, $x + $i - $start );
          refresh( $self->view );
        }
        last;
      };
      case: $key[1] == 1 and do {    # Home
        ( $start ) && ( $self->rfsh( 0, 0 ) );
        $i     = 0;
        $start = 0;
        move( $self->view, $y, $x );
        refresh( $self->view );
        last;
      };
      case: $key[1] == 2 and do {    # Insert
        $OVSTRK_MODE = $OVSTRK_MODE ? 0 : 1;
        last;
      };
      case: $key[1] == 3 and do {    # Del
        if ( $i < length( $self->value ) ) {
          substr( $self->value, $i, 1 ) = "";
          $self->rfsh( $start, $i );
          move( $self->view, $y, $x + $i - $start );
          refresh( $self->view );
        }
        last;
      };
      case: $key[1] == 4 and do {    # End
        $i         = length( $self->value );
        $savestart = $start;
        if ( $start + $len <= length( $self->value ) ) {
          $start = $i - $len + 1;
          $start = 0 if $start < 0;
        }
        if ( $savestart != $start ) {
          $self->rfsh( $start, $i );
        }
        move( $self->view, $y, $x + $i - $start );
        refresh( $self->view );
        last;
      };
      case: $key[1] == 9 and do {    # RightArrow
        if ( $i < length( $self->value ) ) {
          $i++;
          $savestart = $start;
          $start += $jump if $i - $start >= $len;
          if ( $savestart != $start ) {
            $self->rfsh( $start, $i );
          }
          move( $self->view, $y, $x + $i - $start );
          refresh( $self->view );
        } #/ if ( $i < length( $$self...))
        last;
      };
      case: $key[1] == 10 and do {    # LeftArrow
        if ( $i ) {
          $i--;
          $savestart = $start;
          $start -= $jump if $i < $start;
          $start = 0      if $start < 0;
          if ( $savestart != $start ) {
            $self->rfsh( $start, $i );
          }
          move( $self->view, $y, $x + $i - $start );
          refresh( $self->view );
        } #/ if ( $i )
        last;
      };
    } #/ switch: for ( $key[1] )
  } #/ while ( @key = PV::getkey...)
} #/ sub activate

sub stat { # $text_value ($self)
  my $self = shift;
  return $self->value;
}

#--------------------
package PV::Password;
#--------------------
use strict;
use warnings;
use Curses;
use parent -norequire, qw(PV::Entryfield);

# Creates your basic hidden text entry field
# $obj = PV::Password->new($x, $y, $len, $max, $label, $value);
sub new {    # $obj ($class, $x, $y, $len, $max, $label, $value)
  my $class = shift;
  my ( $x, $y, $len, $max, $label, $value ) = @_;
  my $self = $class->SUPER::new( $x, $y, $len, $max, $label, $value );
  return bless $self, $class;
}

sub place {    # void ($self, $start)
  my $self  = shift;
  my $start = shift;
  my ( $len, $value ) = ( $self->len, $self->value );
  move( $self->view, $self->y, $self->x );
  attron( $self->view, COLOR_PAIR( 3 ) );
  addstr( $self->view, $self->label . " " );
  attron( $self->view, COLOR_PAIR( 6 ) );
  attron( $self->view, A_BOLD );
  addstr( $self->view, " " );
  addstr( $self->view, "*" x ( length( substr( $value, $start, $len ) ) ) );
  addstr(
    $self->view,
    "." x ( $len - length( substr( $value, $start, $len ) ) )
  );
  addstr( $self->view, " " );
  attroff( $self->view, A_BOLD );
  return;
} #/ sub place

sub display {    # void ($self)
  my $self = shift;
  $self->place();
  refresh( $self->view );
  return;
}

sub rfsh {    # void ($self, $start, $i)
  my $self  = shift;
  my $start = shift;
  my $i     = shift;
  my ( $len, $value ) = ( $self->len, $self->value );
  if ( $self->max == $start ) {
    move( $self->view, $self->y,
      $self->x + length( $self->label ) + 2 + $i - $start );
    attron( $self->view, COLOR_PAIR( 6 ) );
    attron( $self->view, A_BOLD );
    addstr(
      $self->view,
      "*" x ( length( substr( $value, $i, $len - ( $i - $start ) ) ) )
    );
    addstr(
      $self->view,
      "." x ( $len - ( $i - $start ) - length( substr( $value, $i, $len ) ) )
    );
    attroff( $self->view, A_BOLD );
  } #/ if ( $self->max == $start)
  else {
    $self->max( $start );
    move( $self->view, $self->y, $self->x + length( $self->label ) + 2 );
    attron( $self->view, COLOR_PAIR( 6 ) );
    attron( $self->view, A_BOLD );
    addstr( $self->view, "*" x ( length( substr( $value, $start, $len ) ) ) );
    addstr(
      $self->view,
      "." x ( $len - length( substr( $value, $start, $len ) ) )
    );
    attroff( $self->view, A_BOLD );
  } #/ else [ if ( $self->max == $start)]
  refresh( $self->view );
  return;
} #/ sub rfsh

#--------------------
package PV::Combobox;
#--------------------
use strict;
use warnings;
use Curses;

# A basic combo-box
sub new {    # $obj ($class)
  my $class = shift;
  return bless [], $class;
}

#-------------------
package PV::Viewbox;
#-------------------
use strict;
use warnings;
use Curses;
use Class::Struct
  view    => 'Curses::Window',
  ax      => '$',
  ay      => '$',
  bx      => '$',
  by      => '$',
  text    => '$',
  ln      => '$',
  lines   => '@',
  visible => '@',
  ;

# A readonly text viewer
# $obj = PV::Viewbox->new($x1, $y1, $x2, $y2, $text, $start);
around: {    # $obj ($class, $x1, $y1, $x2, $y2, $text, $start)
  no warnings 'redefine';
  my $orig = \&new; *new = sub {
  my $class = shift;
  my ( $x1, $y1, $x2, $y2, $text, $start ) = @_;
  $text =~ s/[\r\0]//g;        # Strip nulls & DOShit.
  $text =~ s/\t/        /g;    # TABs = 8 spaces.
  $text .= "\n";
  my $lines = $text;
  $lines =~ s/\n/\n\t/g;
  return $class->$orig(
    view  => stdscr,
    ax    => $x1,
    ay    => $y1,
    bx    => $x2,
    by    => $y2,
    text  => $text,
    ln    => $start,
    lines => [ split( "\t", $lines ) ],
  );
}} #/ sub new

sub place {    # void ($self)
  my $self  = shift;
  PV::mybox( $self->ax, $self->ay, $self->bx, $self->by, 0, 1, $self->view );
  $self->rfsh( 1 );
}

sub display {    # void ($self)
  my $self = shift;
  $self->place();
  refresh( $self->view );
}

sub rfsh {    # void ($self, $display)
  my $self    = shift;
  my $display = shift;
  my $dx = $self->bx - $self->ax;
  my $dy = $self->by - $self->ay;
  if ( $self->ln > ( $#{ $self->lines } - $dy + 2 ) ) {
    $self->ln( $#{ $self->lines } - $dy + 2 );
  }
  if ( $self->ln < 0 ) {
    $self->ln( 0 );
  }
  attron( $self->view, COLOR_PAIR( 3 ) );

  my $i = 0;
  foreach ( @{ $self->lines }[ $self->ln .. $self->ln + $dy - 2] ) {
    unless ( $self->visible( $i ) && $self->visible( $i ) eq $_ ) {
      move( $self->view, $self->ay + 1 + $i, $self->ax + 2 );
      my $l = $_;
      $self->visible( $i, $l );
      chop( $l );
      if ( length( $l ) > $dx - 3 ) {
        $l = substr( $l, 0, $dx - 3 );
      }
      addstr( $self->view, $l );
      if ( length( $l ) < $dx - 3 ) {
        addstr( $self->view, " " x ( $dx - 3 - length( $l ) ) );
      }
    } #/ unless ( $self->visible( $i ...))
    $i++;
  } #/ foreach ( @{ $self->lines }[ ...])
  $self->statusbar();
  refresh( $self->view ) unless $display;
  return;
} #/ sub rfsh

sub statusbar {    # void ($self)
  return;
}

# Makes viewer active
sub activate {    # void ($self)
  my $self = shift;
  $self->rfsh;
  move( $self->view, $self->by - 1, $self->bx - 1 );
  refresh( $self->view );
  while ( my @key = PV::getkey() ) {

    switch: {
      case: $key[1] == 18 and do {    # Help
        $self->rfsh;
        return 5;
      };
      case: $key[1] == 19 and do {    # Menu
        $self->rfsh;
        return 6;
      };
      case: $key[1] == 200 and do {
        if ( $key[0] =~ /[\r\t\f]/ ) {
          if ( $key[0] eq "\t" ) {
            $self->rfsh;
            return 7;
          }
        }
        last;
      };
      case: $key[1] == 1 and do {    # Home
        $self->ln( 0 );
        $self->rfsh;
        last;
      };
      case: $key[1] == 4 and do {    # End
        $self->ln( $#{ $self->lines } - $self->by + $self->ay + 2 );
        $self->rfsh;
        last;
      };
      case: $key[1] == 5 and do {    # PgUp
        $self->ln( $self->ln - $self->by - $self->ay - 2 );
        $self->rfsh;
        last;
      };
      case: $key[1] == 6 and do {    # PgDown
        $self->ln( $self->ln + $self->by - $self->ay - 2 );
        $self->rfsh;
        last;
      };
      case: $key[1] == 7 and do {    # UpArrow
        $self->ln( $self->ln - 1 );
        $self->rfsh;
        last;
      };
      case: $key[1] == 8 and do {    # DownArrow
        $self->ln( $self->ln + 1 );
        $self->rfsh;
        last;
      };
    } #/ switch:
  } #/ while ( @key = PV::getkey...)
} #/ sub activate

#-------------------
package PV::Editbox;
#-------------------
use strict;
use warnings;
use Curses;
use Class::Struct
  view    => 'Curses::Window',
  ax      => '$',
  ay      => '$',
  bx      => '$',
  by      => '$',
  margin  => '$',
  text    => '$',
  cp      => '$', # Cursor Position
  ln      => '$', # Line Number
  lines   => '@',
  visible => '@',
  ins     => '$', # Insert
  ;

# More or less a complete editor
# $obj = PV::Editbox->new($x1, $y1, $x2, $y2, $margin, $text, $index, $start);
around: {    # $obj ($class, $x1, $y1, $x2, $y2, $margin, $text, $index, $start)
  no warnings 'redefine';
  my $orig = \&new; *new = sub {
  my $class   = shift;
  my ( $x1, $y1, $x2, $y2, $margin, $text, $index, $start ) = @_;
  $text =~ s/[\r\0]//g;        # Strip nulls & DOShit.
  $text =~ s/\t/        /g;    # TABs = 8 spaces.
  $text .= "\n";
  my $self = $class->$orig(
    view   => stdscr,
    ax     => $x1,
    ay     => $y1,
    bx     => $x2,
    by     => $y2,
    margin => $margin,
    text   => $text,
    cp     => $index,
    ln     => $start,
    ins    => 0,
  );
  $self->justify( 1 );
  return $self;
}} #/ sub new

sub place {    # void ($self)
  my $self = shift;
  PV::mybox( $self->ax, $self->ay, $self->bx, $self->by, 0, 1, $self->view );
  $self->rfsh( 1 );
  return;
}

sub display {    # void ($self)
  my $self = shift;
  $self->place;
  refresh( $self->view );
  return;
}

sub statusbar {    # void ($self)
  return;
}

sub rfsh {    # void ($self, $display)
  my $self    = shift;
  my $display = shift;
  my $start   = $self->ln;
  my @visible = @{ $self->visible };
  my $dy      = $self->by - $self->ay;
  attron( $self->view, COLOR_PAIR( 3 ) );

  my $i = 0;
  foreach ( @{ $self->lines }[ $start .. $start + $dy - 2 ] ) {
    $_           = '' unless defined;                 # $_ //= '';
    $visible[$i] = '' unless defined $visible[$i];    # $visible[$i] //= '';
    if ( $visible[$i] ne $_ ) {
      my $l = $_;
      $self->visible( $i, $l );
      move( $self->view, $self->ay + 1 + $i, $self->ax + 2 );
      chop( $l );
      addstr( $self->view, $l );
      my $padlen = length( $visible[$i] ) - length( $l );
      addstr( $self->view, " " x $padlen ) if $padlen > 0;
    }
    $i++;
  } #/ foreach ( @{ $self->lines }[ $start...])
  $self->statusbar();
  refresh( $self->view ) unless $display;
  return;
} #/ sub rfsh

sub process_key {    # @exitcode ($self, @key)
  return;
}

sub justify {    # void ($self, $mode)
  my $self = shift;
  my $mode = shift;
  my ( $margin, $text, $index ) = ( $self->margin, $self->text, $self->cp );
  my ( $i, $j ) = ( 0, 0 );
  my $line;
  my @text;
  my $ta;
  my $tb;
  my @textqq;
  substr( $text, $index, 0 ) = "\0";
  $text =~ s/ *\n/\n/g;

  if ( $mode ) {
    $ta = "";
    $tb = "";
  }
  else {
    $mode = length( $text );
    ( $ta, $tb ) = split( "\0", $text );
    $ta = $ta . "\0";
    $tb = "\0" . $tb;
    $ta =~ s/(.*)\n\s.*/$1/s;
    $ta = "" if $ta =~ /\0/;
    $tb =~ s/.*?\n\s//s;
    $tb = "" if $tb =~ /\0/;
    $text =
      substr( $text, length( $ta ), $mode - ( length( $ta ) + length( $tb ) ) );
    $mode = 0;
  } #/ else [ if ( $mode ) ]
  $text =~ s/\n/\n\t/g;
  @text = split( "\t", $text );
  $j    = 0;
  for ( $i = 0 ; $j <= $#text ; $i++ ) {
    if ( ( $text[$j] eq "\n" ) || ( $text[$j] eq "\0\n" ) ) {
      $textqq[$i] = $text[$j];
    }
    else {
      if ( length( $text[$j] ) > $margin ) {
        $line = $text[$j];
        $text[$j] = substr( $text[$j], 0, $margin );
        $text[$j] =~ s/^(.*\s+)\S*$/$1/;
        $line = substr( $line, length( $text[$j] ) );
        $line =~ s/^\s*//;
        $text[$j] =~ s/\s*$/\n/;
        if ( $line && $j == $#text ) {
          $text[ $j + 1 ] = $line;
          $textqq[$i] = $text[$j];
        }
        elsif ( $line && $text[ $j + 1 ] =~ /^[\s\0]/ ) {
          $textqq[$i] = $text[$j];
          $text[$j]   = $line;
          $j--;
        }
        else {
          $line =~ s/\n$//;
          $line =~ s/(\S)$/$1 /;
          $textqq[$i] = $text[$j];
          $text[ $j + 1 ] = $line . $text[ $j + 1 ];
        }
      } #/ if ( length( $text[$j]...))
      elsif ( !$mode
        && $j < $#text
        && length( $text[$j] ) + length( ( split( " ", $text[ $j + 1 ] ) )[0] ) <
        $margin
        && $text[ $j + 1 ] =~ /^[^\s\0]/ )
      {
        chop( $text[$j] );
        $text[$j] .= " " if $text[$j] !~ /\s$/;
        $text[$j] .= $text[ $j + 1 ];
        $textqq[$i] = $text[$j];
        $text[ $j + 1 ] = $text[$j];
        $i--;
      } #/ elsif ( !$mode && $j < $#text...)
      else {
        $textqq[$i] = $text[$j];
      }
    } #/ else [ if ( ( $text[$j] eq "\n"...))]
    $j++;
  } #/ for ( $i = 0 ; $j <= $#text...)
  $text  = join( "", @textqq );
  $text  = $ta . $text . $tb;
  $index = length( ( split( "\0", $text ) )[0] );
  substr( $text, $index, 1 ) = "";
  $self->cp( $index );
  $self->text( $text );
  $text =~ s/\n/\n\t/g;
  $self->lines( [ split( "\t", $text ) ] );
  return;
} #/ sub justify

sub cursor {    # $col, $line, $len ($self)
  my $self = shift;
  my ( $x1, $y1, $y2, $start ) = ( $self->ax, $self->ay, $self->bx, $self->ln );
  my $textthis = substr( $self->text, 0, $self->cp + 1 );
  my $col      = 0;
  my $line     = ( $textthis =~ tr/\n// );
  if ( $textthis =~ /\n$/ ) {
    $line-- if $line;
    $col++;
  }
  my $len  = length( $self->lines->[$line] ) - 1;
  my @cols = split( "\n", $textthis );
  $col += length( $cols[$line] ) || 0;
  if ( $line < $start ) {
    $start = $line;
  }
  elsif ( $line >= $start + $y2 - $y1 - 1 ) {
    $start = $line - $y2 + $y1 + 2;
    $start = 0 if $start < 0;
  }
  if ( $self->ln != $start ) {
    $self->ln( $start );
    $self->rfsh;
  }
  move( $self->view, $y1 + $line - $start + 1, $col + $x1 + 1 );
  return ( $col, $line, $len );
} #/ sub cursor

sub linemove {    # void ($self, $dir, $count)
  my $self  = shift;
  my $dir   = shift;
  my $count = shift;
  my ( $col, $line, $len ) = $self->cursor;
  if ( $dir ) {
    if ( $line + $count > $#{ $self->lines } ) {
      $count = $#{ $self->lines } - $line;
    }
    if ( $count ) {
      $self->cp( $self->cp + $len - $col + 1 );
      ( length( $self->lines->[ $line + $count ] ) < $col )
        && ( $col = length( $self->lines->[ $line + $count ] ) );
      $self->cp( $self->cp + $col );
      $count--;
      while ( $count ) {
        $self->cp( $self->cp + length( $self->lines->[ $count + $line ] ) );
        $count--;
      }
    } #/ if ( $count )
  } #/ if ( $dir )
  elsif ( $line ) {
    $count = $line if $line - $count < 0;
    $self->cp(
      $self->cp - $col + length( $self->lines->[ $line - $count ] ) );
    if ( length( $self->lines->[ $line - $count ] ) < $col ) {
      $col = length( $self->lines->[ $line - $count ] );
    }
    $self->cp( $self->cp + $col );
    $count--;
    while ( $count ) {
      $self->cp( $self->cp - length( $self->lines->[ $line - $count ] ) );
      $count--;
    }
  } #/ elsif ( $line )
  return;
} #/ sub linemove

sub e_bkspc {    # void ($self)
  my $self = shift;
  my ( $col, $line, $len ) = $self->cursor;
  if ( $self->cp ) {
    $self->cp( $self->cp - 1 );
    if ( substr( $self->text, $self->cp, 1 ) eq "\n" ) {
      substr( $$self[6], $self->cp, 1 ) = "";
      $self->justify;
    }
    else {
      substr( $$self[6],        $self->cp, 1 ) = "";
      substr( $$self[9][$line], $col - 2,  1 ) = "";
    }
    $self->rfsh;
  } #/ if ( $self->cp )
  return;
} #/ sub e_bkspc

sub e_del {    # void ($self)
  my $self = shift;
  my ( $col, $line, $len ) = $self->cursor;
  unless ( $self->cp == length( $self->text ) - 1 ) {
    if ( substr( $self->text, $self->cp, 1 ) eq "\n" ) {
      substr( $$self[6], $self->cp, 1 ) = "";
      $self->justify;
    }
    else {
      substr( $$self[6],        $self->cp, 1 ) = "";
      substr( $$self[9][$line], $col - 1,     1 ) = "";
    }
    $self->rfsh;
  } #/ unless ( $self->cp == length...)
} #/ sub e_del

sub e_ins {    # void ($self, $keystroke)
  my $self      = shift;
  my $keystroke = shift;
  $keystroke = "\n" if $keystroke =~ /\n|\r\n?/;
  my ( $col, $line, $len ) = $self->cursor;
  if ( substr( $self->text, $self->cp, 1 ) eq "\n" ) {
    substr( $$self[6],        $self->cp, 0 ) = $keystroke;
    substr( $$self[9][$line], $col - 1,  0 ) = $keystroke;
  }
  else {
    substr( $$self[6],        $self->cp, $self->ins ) = $keystroke;
    substr( $$self[9][$line], $col - 1,  $self->ins ) = $keystroke;
  }
  $self->cp( $self->cp + 1 );
  if ( ( length( $self->lines->[$line] ) >= $self->margin )
    || ( $keystroke eq "\n" ) )
  {
    $self->justify;
  }
  $self->rfsh;
  return;
} #/ sub e_ins

sub stat {    # $text_value ($self)
  my $self = shift;
  return $self->ln;
}

# Makes editbox active
sub activate {    # $cmd ($self)
  my $self = shift;
  my $dy = $self->by - $self->ay;
  my @exitcode;
  $self->rfsh;
  my ( $col, $line, $len ) = $self->cursor;
  refresh( $self->view );

  while ( my @key = PV::getkey() ) {

    if ( $key[1] == 18 ) {    # Help
      $self->rfsh;
      return 5;
    }
    elsif ( $key[1] == 19 ) {    # Menu
      $self->rfsh;
      return 6;
    }
    else {                       # Process key hook for subclasses
      @exitcode = ( $self->process_key( @key ) );
      if ( $exitcode[0] == 1 ) {
        $self->rfsh;
        return 8;
      }
      elsif ( $exitcode[0] == 2 ) {
      }
      else {    # Now defaults for the editbox.
        if ( $exitcode[0] == 3 ) {
          @key = @exitcode[ 1 .. 2 ];
        }
        switch: {
          case: ( $key[1] == 11 ) and do {
            $self->e_bkspc();
            last;
          };
          case: ( $key[1] == 200 ) && ( $key[0] eq "\t" ) and do {
            $self->rfsh;
            return 7;
          };
          case: ( $key[1] == 200 ) && ( $key[0] =~ /\r\f/ ) and do {
            pv::redraw();
            return 0;
          };
          case: ( $key[1] == 200 ) and do {
            $self->e_ins( $key[0] );
            last;
          };
          case: ( $key[1] == 2 ) || ( $key[1] == 21 ) and do {
            $self->ins( $self->ins ? 0 : 1 );
            last;
          };
          case: ( $key[1] == 3 ) || ( !$key[1] && $key[0] eq "\cD" ) and do {
            $self->e_del();
            last;
          };
          case: ( $key[1] == 1 ) || ( !$key[1] && $key[0] eq "\cA" ) and do {    # Home
            $self->cp( $self->cp - ( $self->cursor )[0] - 1 );
            last;
          };
          case: ( $key[1] == 4 ) || ( !$key[1] && $key[0] eq "\cE" ) and do {    # End
            $self->cp( $self->cp 
              + ( $self->cursor )[2] - ( ( $self->cursor )[0] - 1 ) );
            last;
          };
          case: ( $key[1] == 5 ) || ( $key[1] == 15 ) and do {                   # PgUp
            $self->linemove( 0, $dy - 2 );
            last;
          };
          case: ( $key[1] == 6 ) || ( !$key[1] && $key[0] eq "\cV" ) and do {    # PgDown
            $self->linemove( 1, $dy - 2 );
            last;
          };
          case: ( $key[1] == 7 ) || ( !$key[1] && $key[0] eq "\cP" ) and do {    # UpArrow
            $self->linemove( 0, 1 );
            last;
          };
          case: ( $key[1] == 8 ) || ( !$key[1] && $key[0] eq "\cN" ) and do {    # DownArrow
            $self->linemove( 1, 1 );
            last;
          };
          case: ( $key[1] == 9 ) || ( !$key[1] && $key[0] eq "\cF" ) and do {    # RightArrow
            unless ( $self->cp == length( $self->text ) - 1 ) {
              $self->cp( $self->cp + 1 );
            }
            last;
          };
          case: ( $key[1] == 10 ) || ( !$key[1] && $key[0] eq "\cB" ) and do {    # LeftArrow
            if ( $self->cp ) {
              $self->cp( $self->cp - 1 );
            }
            last;
          };
        } #/ switch:
        $self->cursor;
        $self->statusbar();
        ( $col, $line, $len ) = $self->cursor;
        refresh( $self->view );
      } #/ else [ if ( $exitcode[0] == 1)]
    } #/ else [ if ( $key[1] == 18 ) ]
  } #/ while ( my @key = PV::getkey...)
} #/ sub activate

#------------------
package PV::Dialog;
#------------------
use strict;
use warnings;
use Curses;
use Class::Struct
  view    => 'Curses::Window',
  label   => '$',
  ax      => '$',
  ay      => '$',
  bx      => '$',
  by      => '$',
  style   => '$',
  bkcolor => '$',
  ;

# The dialog box object
# $obj = PV::Dialog->new("Label", $x1, $y1, $x2, $y2, $style, $color,
#     control1, 1, 2, 3, 4, 5, 6, 7, 8,
#     control2, 1, 2, 3, 4, 5, 6, 7, 8, ...);
around: {    # $obj ($class, $label, $x1, $y1, $x2, $y2, $style, $color, @controls)
  no warnings 'redefine';
  my $orig = \&new; *new = sub {
  my $class = shift;
  my ( $label, $x1, $y1, $x2, $y2, $style, $color, @controls ) = @_;
  my $dx = $x2 - $x1;
  my $dy = $y2 - $y1;
  my $win = newwin( $dy + 1, $dx + 1, $y1 - 1, $x1 - 1 );
  my $self = $class->$orig(
    view    => $win,
    label   => $label,
    ax      => $x1,
    ay      => $y1,
    bx      => $x2,
    by      => $y2,
    style   => $style,
    bkcolor => $color,
  );
  push @$self, @controls;
  return $self;
}} #/ sub new

sub display {    # void ($self)
  my $self = shift;
  my $width = $self->bx - $self->ax;
  my $height = $self->by - $self->ay;
  # PV::mybox( 0, 0, $width, $height, 1, 1, $self->view );
  PV::mybox( 0, 0, $width, $height, $self->style, $self->bkcolor, $self->view );
  my $i = 8;
  while ( 7 + $i < $#$self ) {
    $self->[$i]->view( $self->view );
    $self->[$i]->place;
    $i += 9;
  }
  refresh( $self->view );
  return;
} #/ sub display

sub activate {    # $ctrl, $cmd ($self)
  my $self = shift;
  $self->display;
  my $i    = 1;
  my @last = ();
  while ( $i ) {
    my $ctrl = 8 + ( $i - 1 ) * 9;
    my $cmd  = $self->[$ctrl]->activate;
    @last = ( $i, $cmd );
    $i    = $self->[ $ctrl + $cmd ];
  }
  $self->hide;
  refresh( $self->view );
  return @last;
} #/ sub activate

sub hide {    # void ($self)
  my $self = shift;
  touchwin( stdscr );
  refresh( stdscr );
  return;
}

# Two commonly needed dialog box types
#---------------
package PV::PVD;
#---------------
use strict;
use warnings;

sub message {    # void ($self, $message, $width, $height)
  my ( $message, $width, $height ) = @_;
  $width = 11 if $width < 11;
  $height += 4;
  my $x1     = int( ( 80 - $width ) / 2 );
  my $y1     = 4 + int( ( 19 - $height ) / 2 );
  my $x2     = $x1 + $width;
  my $y2     = $y1 + $height;
  my $static = PV::Static->new( $message, 2, 1, $x2 - $x1, $y2 - $y1 - 4 );
  my $ok     = PV::Cutebutton->new( " OK ", int( $width / 2 ) - 3, $y2 - $y1 - 2 );
  my $dialog = PV::Dialog->new(
    "",      $x1, $y1, $x2, $y2, 1, 1,
    $ok,     1,   1,   1,   1,   1, 1, 1, 0,
    $static, 0,   0,   0,   0,   0, 0, 0, 0
  );
  $dialog->activate;
  return;
} #/ sub message

sub yesno {    # $cmd ($self, $message, $width, $height)
  my ( $message, $width, $height ) = @_;
  my @message = split( "\n", $message );
  $width = 21 if $width < 21;
  $height += 4;
  my $x1     = int( ( 80 - $width ) / 2 );
  my $y1     = 4 + int( ( 19 - $height ) / 2 );
  my $x2     = $x1 + $width;
  my $y2     = $y1 + $height;
  my $static = PV::Static->new( $message, 2, 1, $x2 - $x1, $y2 - $y1 - 4 );
  my $yes = PV::Cutebutton->new( " YES ", int( $width / 2 ) - 9, $y2 - $y1 - 2 );
  my $no  = PV::Cutebutton->new( " NO ",  int( $width / 2 ) + 2, $y2 - $y1 - 2 );
  my $dialog = PV::Dialog->new(
    "",      $x1, $y1, $x2, $y2, 1, 1,
    $yes,    1,   1,   2,   1,   1, 1, 2, 0,
    $no,     2,   3,   2,   1,   2, 2, 1, 0,
    $static, 0,   0,   0,   0,   0, 0, 0, 0
  );
  my ( $stat ) = $dialog->activate;
  $stat = 0 if $stat == 2;
  return $stat;
} #/ sub yesno

1;

__END__

=head1 NAME

PerlVision - Text-mode User Interface Widgets.

=head1 VERSION

Version 1.5

=head1 SYNOPSIS

  use PV;

  init PV;

  my $foo = PV::Static->new("Text", $x1, $y1, $x2, $y2);
  $foo->display;

=head1 DESCRIPTION

Once upon a time I needed a basic text-mode GUI framework to implement
some nice-looking interfaces for the Linux console. Didn't find any
around, so necessity became the mother of PerlVision, which kept
growing as I kept adding more goodies, so now it's far from basic...

PV provides 90% of the features you'd want for a user interface,
including checkboxes, radiobuttons, three different styles (!) of
pushbuttons, single and multiple selection listboxes, an extensible
editbox, a scrollable viewbox, single line text entry fields, a
menubar with pulldown menus, and full popup dialog boxes with multiple
controls.

=head1 CLASSES

The following object classes are defined within PV:

=over 2

=item B<PV::Static>

A static text region, trivial class.

=item B<PV::Checkbox>

A single 2-state checkbox.

=item B<PV::Radio>

A single 2-state radiobutton.

=item B<PV::RadioG>

A group of connected radiobuttons.

=item B<PV::Listbox>

A single selection list box.

=item B<PV::Mlistbox>

A multiple selection list box.

=item B<PV::Entryfield>

A single line text entry field.

=item B<PV::Password>

A single line text entry field that *'s out what's typed.

=item B<PV::Menubar>

A top line menu bar with single-level pulldown submenus.

=item B<PV::Combobox>

A combo box.

=item B<PV::Editbox>

A multi line edit box.

=item B<PV::Viewbox>

A readonly viewer/pager for text files.

=item B<PV::Pushbutton>

A push button that takes 3 lines of screen real estate.

=item B<PV::Cutebutton>

A push button that takes 2 lines of screen real estate.

=item B<PV::Plainbutton>

A no-frills button that fits on a single line.

=item B<PV::Dialog>

A full dialog box with as many controls as you like.

=back

=over 2

=item *

Other classes are defined for internal use by PerlVision and should
not be used from outside. Also, see below why use of the PV::Radio
control is limited from outside.

=item * 

Constructors for all the classes are called new().

=item * 

All classes expect that you will not fiddle with the object's data
yourself.

=item * 

All nontrivial controls (except PV::RadioG, see below) have an
activate() method. It makes the control active, and returns when any
traditional shift focus key is pressed - see the section on PV::Dialog
for more details.

=item * 

All nontrivial controls have a stat() method, which returns the status
of the control (checked, unchecked, text, whatever).

=back

=head1 PV::Static

  my $foo = PV::Static->new("Text", $x1, $y1, $x2, $y2);

This is the trivial text region control. It's there mainly so you can
put static text in dialog boxes. It doesn't have an activate() or
stat() method.

  $foo->display;      # Displays the widget.  

If your text doesn't fit in the space you allocate, it'll be
truncated. It's also your responsibility to provide line breaks if you
don't want all the text to be thought of as a single line.

=head1 PV::Checkbox

  my $foo = PV::Checkbox->new("Label", $x, $y, $stat);

Arguments $x and $y are the X and Y co-ordinates to place the control.
$stat is 1 if the Checkbox is checked, 0 if not. "Label" is printed on
the left of the checkbox.

  $foo->display;      # Displays checkbox.
  $foo->activate;     # Gives it focus. Exits on 1,2,3,4,5,6,7 codes.
  $foo->select;       # Toggles status.
  $foo->stat;         # Returns status. (1 checked, 0 unchecked)

=head1 PV::Radio

  my $foo = PV::Radio->new("Label", $x, $y, $stat);

PV::Radio is a direct descendant of PV::Checkbox that just looks a bit
different. All the methods defined for PV::Checkbox are defined for
PV::Radio as well, But don't try to use PV::Radio as a different
looking PV::Checkbox.

Because radio buttons are generally meant to be grouped and to affect
the state of all other buttons in the group. So unless you include a
radio button in a group with PV::RadioG (see below), you're liable to
hurt something. Once it's in a group you can use all the methods
outlined above for PV::Checkbox.

=head1 PV::RadioG

  my $foo = PV::RadioG->new($radio_1, $radio_2, $radio_3...);

Where $radio_* are PV::Radio objects. See? You take your PV::Radio
objects, and feed them to the constructor for PV::RadioG, and out pops
a radio button group.

  $foo->display;      # Displays all radio buttons in group.
  $foo->stat;         # To figure out which button is the one that's
                      # selected. This returns the Label of the selected
                      # button.

PV::RadioG has no 'activate' method. You activate the PV::Radio
objects directly. This is much more flexible for use in dialog boxes.

=head1 PV::Listbox

  my $foo = PV::Listbox->new("Head", $x1, $y1, $x2, $y2, 
                             "Label1", 0, "Label2", 0...);

Yes, the element following each "Labeln" should be 0 for this to work
right.

"Label*" are the strings that will be shown in the listbox. "Head"
will be printed across above the top of the listbox.

  $foo->activate;     # Gives it focus. Exits on 5,6,7,8 exit codes.
  $foo->stat;         # Returns the label of the selected entry.

=head1 PV::Mlistbox

  my $foo = PV::Mlistbox->new("Head", $x1, $y1, $x2, $y2, 
                              "Label1", 0, "Label2", 0...);

Yes, the element following each "Labeln" should be 0 for this to work
right.

"Label*" are the strings that will be shown in the listbox. "Head"
will be printed across above the top of the listbox.

  $foo->activate;     # Gives it focus. Exits on 5,6,7,8 exit codes.
  $foo->stat;         # Returns a list of all selected labels.

=head1 PV::Entryfield

  my $foo = PV::Entryfield->new($x, $y, $length, $max,
                                "Label", "Initial Value");

$length is the length of the text entry area. $max is the maximum
length of the input. actually this is ignored. ;-) "Label" is printed
to the left of the entry field. Can be "".  The entryfield is
pre-initialized to "Initial Value". Can be "".

  $foo->activate;     # Gives it focus. Exits on 1,2,5,6,7,8 exit codes.
                      # Changed text is always saved, regardless of
                      # how the loop exited.
  $foo->stat;         # Returns the text value of the entryfield.

=head1 PV::Password

Identical to PV::Entryfield except that it displays '*'s instead of
what the user types.

=head1 PV::Menubar

The menu bar is a bit odd. The way you do it is set it up with just
one pulldown, then add pulldowns to it till you have enough. Don't add
too many (i.e. that there's not enough space for their heads on the
menubar) or things will definitely get broken.

  my $foo = PV::Menubar->new("Head", $width, $height, 
                             "label1", 0, "label2", 0...);

Just like with the listboxes, each list element is followed by a
0. This list becomes your first pulldown. Now to add more pulldowns,
do:

  $foo->add("Head", $width, $height, "label1", 0, "label2", 0...);

That's the second pulldown, and so on. Because of this step by step
method of building up the menubar, you need to display it once you're
finished adding pulldowns, it doesn't automatically display itself. Do
a:

  $foo->display();

To activate:

  $foo->activate();

It'll exit on 5, 7, and 8. On 8, it'll give you a second element in
the return list of the form "Pulldown:Selection". The "Pulldown" is
the head of the pulldown menu, the "Selection" is the label of the
selection.

Help context does not come through on the 5 exit code. i.e. you can't
tell which pulldown was active when help was requested, or which
selection in which pulldown. C'est la vie.

=head1 PV::Combobox

Not implemented yet. I'll get around to it when I need it I guess.
Actually it's a pretty trivial offspring of a listbox and an
entryfield.

=head1 PV::Editbox

  my $foo = PV::Editbox->new($x1, $y1, $x2, $y2, $margin, 
                             "Text", $index, $start);

$margin is the word-wrap boundary. If it's bigger than the size of the
box, that's your headache.

$text is a text string to be dumped into the editbox. it will be
stripped of CRs (not LFs), TABs, and nulls, and justified the way the
editbox does it (see below).

$index is the start position within the text to initially place the
cursor at. First char is 0.

$start is the line number to position at the top of the editbox, if
possible. First line is 0.

  $foo->activate;   # Gives it focus. Exits on 5,6,7 exit codes.
                    # Changed text is always saved, regardless of
                    # how the loop exited.
  $foo->stat;       # Returns the text value of the editbox.

There are some hooks in there to let you subclass it and do
things. One is an empty 'sub statusbar' that's called every-time the
display is refreshed. Another is an empty 'sub process_key' which is
used extensively in rap to build a full editor out of the editbox
control.

The editbox does automatic word-wrapping and reverse word-wrapping and
other fancy stuff. The style of auto-wrapping I chose is what
personally irritates me the least (all auto-wraps irritate me). Trying
to change the wrap style is likely to be very hairy, and will probably
break the editbox. It took a lot of tweaking of plenty of regexps to
get it to work the way it does.

=head1 PV::Viewbox

  my $foo = PV::Viewbox->new($x1, $y1, $x2, $y2, $text, $start);

Much like PV::Editbox but it's readonly and the arrow keys have
different bindings. I will eventually implement hardware scrolling in
viewboxes that extend the length of the display so that it's a fast
browser.

=head1 PV::Pushbutton, PV::Cutebutton, PV::Plainbutton

  my $foo = PV::Pushbutton->new("Label", $x1, $y1);

Makes a simple push button.

  $foo->display();    # Displays it.
  $foo->activate();   # Activates it.

Exits on codes 1,2,3,4,5,6,7,8. On 8, it 'depresses' and it's up to
you to 'undepress' it by calling the display method.

PV::Pushbutton is BIG. It takes 3 lines on the screen. PV::Cutebutton is
my favorite - it takes only two lines, and actually pushes and pops
around so it's fun to watch ;) PV::Plainbutton is a basic one-line
button which does absolutely nothing fancy but is very useful in some
situations (e.g. for hyper-text).

=head1 PV::Dialog

This is the guy that puts it all together and does all the work of
managing how focus switches between multiple controls in a dialog
box. Once you've created all the controls you need, you can feed them
to PV::Dialog and out pops an object that you can trust to handle
everything. Above you would have noticed that the activate loops for
all controls return en exit code when focus is released. This is what
these codes mean:

When an activate loop exits, it returns a code telling you the reason
for exiting:

1 = Up Arrow            (Traditional shift-focus key)

2 = Down Arrow          (Traditional shift-focus key)

3 = Right Arrow         (Traditional shift-focus key)

4 = Left Arrow          (Traditional shift-focus key)

5 = M-h                 (For help)

6 = M-x                 (For menu)

7 = Tab                 (Traditional shift-focus key)

8 = Enter               (Traditional 'Done here' key)

These codes are used by the PV::Dialog control to figure out how to
switch focus between controls, and when to exit. Here's how to create
a PV::Dialog object:

  $foo = PV::Dialog->new("Title", $x1, $y1, $x2, $y2, $style, $color,
                         $control1, 1, 2, 2, 1, 1, 1, 2, 0,
                         $control2, 1, 3, 3, 1, 2, 2, 3, 0,
                         ...);

"Title" is currently ignored.

$style: if 1, creates a popup that is 'raised'.
        if 0, creates a popup that is 'depressed'

$color is the background color for the dialog. I'd recommend 6 (cyan)
because of the overall hardcoded buddha-nature of colors at present.

$control* are PV::* objects that you created beforehand (I think they
can even be PV::Dialog types, though I haven't tested it. They can't
be PV::Menubar types). Note that the controls must be positioned
relative to the origin of the dialog box, not relative to the screen
origin (dialog boxes are actually curses windows, and that's how
curses likes it).

How the dialog box works is that the control+exitcode matrix tells
PV::Dialog which control to switch focus to on each of the 8 exit
codes listed above. So when you do a:

  $foo->activate;

PV::Dialog starts off by displaying itself and giving focus to
$control1. When $control1 exits, $foo looks in the list that follows
$control1 in the constructor syntax above to figure out which control
to give focus to next. The list is simply numbers that say which
control. So 1 represents $control1, 2 represents $control2, and so on,
strictly based on the order in which the controls appear in the
constructor invocation.

The special value 0 is reserved to tell PV::Dialog that it's time to
exit and hide the dialog box. I also use it as a place-holder for
those exit-codes that a certain control never returns, for example of
$control1 above was a PV::Editbox, I'd put 0's in the list following
$control1 at positions 1,2,3 and 4 because the edit box object never
exits on those codes (those keys have meaning within the editbox)

If you don't want focus to switch off a control when a certain
exitcode is returned, simply put that control's own number in the
corresponding position in the list.

Look in the rap code for an example of PV::Dialog use, the $options
object. It's generally very easy and powerful.

When PV::Dialog's activate exits, it returns a two-element list. First
element tells you which was the last control to be active (again
numbered as they appear in the constructor invocation), and the second
element tells you what exitcode that control returned.

After the dialog box has exited, you can call 'stat' on each control
to find out what's up. Remember, don't put PV::RadioG controls in a
dialog box, they don't have an activate method. Put the corresponding
PV::Radio controls in. When you 'stat', you'll be 'stat'ing the
PV::RadioG.

Also, don't ever put a PV::Static as the first control in a
PV::Dialog. It doesn't have an activate method. If you just want a
pop-up box with text and no other controls, either consider using a
PV::Viewbox control, or write the text onto the popup box yourself with
pv::pvprint.

=head1 Goodies: PV::PVD

PerlVision also defines two often needed dialog box styles:

  PV::PVD::message  (A simple message box with OK button)
  PV::PVD::yesno    (An option box with Yes/No buttons)

Both self-center, and make sure the box is big enough to hold the
buttons. They don't bother to check if the screen will hold the dialog
box, or the dialog box will hold your text. Both use the following
syntax:

  $foo = PV::PVD::message->new("Text", $width, $height);

PV::PVD::yesno returns 1 for yes and 0 for no.

Width and height are how big you want the text part of the box to be
(the buttons are separate).

=head1 BUGS

=over 2

=item * 

$max in PV::Entryfield is a misnomer. It's actually used internally
and should be set to 0 when you create a new entryfield object.

=item * 

Colors are still more-or-less hardcoded.

=item * 

Some vestigal crufts from v0.1 remain, as the rewrite to use curses
was accomplished by blatant abuse of emacs's M-x replace-regexp.  In
particular, all controls still expect X co-ordinates before Y
co-ordinates, which is the reverse of how curses likes it. In a future
version I'll do away with positional arguments and use hash arguments.

=item * 

PV.pm should check if the terminal can support the minimum
capabilities required, as well as eval uncertain curses calls.

=item *

Error checking needs work. 

=item *

PV languished for many (4) years without any updates but I am hoping
to get a chance to clean it up soon. A lot needs to be worked on - too
much to list here.

=back

=head1 HISTORY

=over 2

=item B<v0.1> 

March 1995. First release. Didn't use curses, did its own screen
optimization, which was in Perl and very slow.

=item B<v0.2>

April 1995. Found Will Setzer's Curses interface for Perl and did a
rewrite using curses/ncurses. Tremendously speeded up and much more
portable. Turned into a real Perl 5 module. Many thanx to Tim Bunce
for helping clear up my confusion about modules.

=item B<v1.x>

July 2000. Moved docs to pod format and put PV in CVS. Brought PV
packaging up to date with a 2 digit version number and a
Makefile.PL. Hopefully this means I am going to finally do some work
on PV soon!

=back

=head1 SEE ALSO 

Curses(3), perl(1).

=head1 AUTHOR

PerlVision is Copyright (c) 2000 Ashish Gulhati
<hash@netropolis.org>. All Rights Reserved.

=head1 CONTRIBUTORS

Nick Cabatoff <ncc@cs.mcgill.ca>

=head1 ACKNOWLEDGEMENTS

Thanks to Barkha for inspiration and lots of good times; to Raj for
the good old days when we hacked Unix and consumed insane quantities
of alcohol; to Emily Saliers, Eddie Van Halen and Neil Peart for
fantastic music; to William Setzer for Perl Curses, Larry Wall for
Perl, and RMS for Emacs.

=head1 LICENSE

This code is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

It would be nice if you would mail your patches to me, and I would
love to hear about projects that make use of this module.

=head1 DISCLAIMER

This is free software. If it breaks, you own both parts.

=cut
