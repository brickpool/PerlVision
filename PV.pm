require 5.000;

# PerlVision - A class library for text-mode user interface widgets.
# By Ashish Gulhati (hash@netropolis.org)
# V.0.2.0
#
# Copyright (c) Ashish Gulhati, 1995. All Rights Reserved.
#
# Free electronic distribution permitted. You are free to use
# PerlVision in your own code so long as this copyright message stays
# intact. PerlVision or derived code may not be used in any commercial
# product without my prior written or PGP-signed consent. Please e-mail
# me if you make significant changes, or just want to let me know what
# you're using PerlVision for.

package PV;
use Curses;

sub init {			# Sets things up
    initscr();
    raw(); noecho();
    eval {
	keypad(1);
    };
    eval {
	start_color();
	init_pair(1,COLOR_BLACK,COLOR_WHITE);
	init_pair(2,COLOR_WHITE,COLOR_WHITE);
	init_pair(3,COLOR_BLACK,COLOR_CYAN);
	init_pair(4,COLOR_WHITE,COLOR_CYAN);
	init_pair(5,COLOR_BLUE,COLOR_WHITE);
	init_pair(6,COLOR_WHITE,COLOR_BLUE);
	init_pair(7,COLOR_BLUE,COLOR_CYAN);
    };
}

sub mybox {			# Draws your basic 3D box.
    my ($x1,$y1,$x2,$y2,$style,$color,$window)=@_;
    my $lines=$x2-$x1;
    my $j;
    my ($TOPL,$BOTR);
    if ($style) {$TOPL=1; $BOTR=0}
    else {$TOPL=0; $BOTR=1}
    move ($window,$y1,$x1); 
    attron ($window,COLOR_PAIR(1+$TOPL+$color*2));
    $TOPL ? attron ($window,A_BOLD) : attroff ($window,A_BOLD);
    addch ($window,ACS_ULCORNER); hline ($window,ACS_HLINE, $lines-1); 
    attron ($window,COLOR_PAIR(1+$BOTR+$color*2));
    $BOTR ? attron ($window,A_BOLD) : attroff ($window,A_BOLD);
    move ($window,$y1,$x1+$lines); 
    addch ($window,ACS_URCORNER); 
    move ($window,$y1+1,$x1);
    attron ($window,COLOR_PAIR(1+$TOPL+$color*2));
    $TOPL ? attron ($window,A_BOLD) : attroff ($window,A_BOLD);
    vline ($window,ACS_VLINE, $y2-$y1-1);
    move ($window,$y1+1,$x1+$lines);
    attron ($window,COLOR_PAIR(1+$BOTR+$color*2));
    $BOTR ? attron ($window,A_BOLD) : attroff ($window,A_BOLD);
    vline ($window,ACS_VLINE, $y2-$y1-1);
    move ($window,$y2,$x1); 
    attron ($window,COLOR_PAIR(1+$TOPL+$color*2));
    $TOPL ? attron ($window,A_BOLD) : attroff ($window,A_BOLD);
    addch ($window,ACS_LLCORNER); 
    attron ($window,COLOR_PAIR(1+$BOTR+$color*2));
    $BOTR ? attron ($window,A_BOLD) : attroff ($window,A_BOLD);
    hline ($window,ACS_HLINE, $lines-1);
    move ($window,$y2,$x1+$lines); 
    addch ($window,ACS_LRCORNER); 
    for ($j=$y1+1; $j<$y2; $j++) {
	move ($window,$j,$x1+1);
	addstr ($window," " x ($lines-1));
    }
    attroff ($window,A_BOLD);
}

sub getkey {			# Gets a keystroke and returns a code
    my $key = getch();		# and the key if it's printable.
    my $keycode = 0;
    if ($key == KEY_HOME) {
	$keycode = 1;
    }
    elsif ($key == KEY_IC) {
	$keycode = 2;
    }
    elsif ($key == KEY_DC) {
	$keycode = 3;
    }
    elsif ($key == KEY_END) {
	$keycode = 4;
    }
    elsif ($key == KEY_PPAGE) {
	$keycode = 5;
    }
    elsif ($key == KEY_NPAGE) {
	$keycode = 6;
    }
    elsif ($key == KEY_UP) {
	$keycode = 7;
    }
    elsif ($key == KEY_DOWN) {
	$keycode = 8;
    }
    elsif ($key == KEY_RIGHT) {
	$keycode = 9;
    }
    elsif ($key == KEY_LEFT) {
	$keycode = 10;
    }
    elsif ($key == KEY_BACKSPACE) {
	$keycode = 11;
    }
    elsif ($key eq "\e") {
	$key = getch();
	if ($key =~ /[WwBbFfIiQqVv<>DdXxHh]/) { # Meta keys
	    ($key =~ /[Qq]/) && ($keycode = 12);   # M-q
	    ($key =~ /[Bb]/) && ($keycode = 13);   # M-b
	    ($key =~ /[Dd]/) && ($keycode = 14);   # M-d
	    ($key =~ /[Vv]/) && ($keycode = 15);   # M-v
	    ($key eq "<") && ($keycode = 16);      # M-<
	    ($key eq ">") && ($keycode = 17);      # M->
	    ($key =~ /[Hh]/) && ($keycode = 18);   # M-h
	    ($key =~ /[Xx]/) && ($keycode = 19);   # M-x
	    ($key =~ /[Ff]/) && ($keycode = 20);   # M-f
	    ($key =~ /[Ii]/) && ($keycode = 21);   # M-i
	    ($key =~ /[Ww]/) && ($keycode = 22);   # M-w
	}
	else {
	    $keycode = 100;
	}
    }
    elsif ($key =~ /[A-Za-z0-9_ \t\n\r~\`!@#\$%^&*()\-+=\\|{}[\];:'"<>,.\/?]/) {
        ($keycode = 200);
    }
    return ($key, $keycode);
}

package PV::Static;		# Trivial static text class for dialog boxes
use Curses;

sub new {
    my $type=shift;
    my @params=(stdscr,@_);
    my $self=\@params;
    bless $self;
}

sub place {
    my $self=shift;
    my ($message,$x1,$y1,$x2,$y2)=@$self[1..5];
    my @message=split("\n",$message);
    my $width=$x2-$x1;
    my $depth=$y2-$y1;
    my $i=$y1;
    attron ($$self[0],COLOR_PAIR(3));
    foreach (@message[0..$depth]) {
	move ($$self[0],$i,$x1);
	addstr ($$self[0],substr ($_,0,$width));
	$i++;
    }
}

sub display {
    my $self=shift;
    $self->place;
    refresh ($$self[0]);
}

package PV::Checkbox;
use Curses;

sub new {			# Creates your basic check box
    my $type = shift;		# $foo = new PV::Checkbox (Label,x,y,stat);
    my @params = (stdscr,@_);		
    my $self = \@params;
    bless $self;
    return $self;
}

sub place {			
    my $self = shift;		
    move ($$self[0],$$self[3],$$self[2]); 
    attron ($$self[0],COLOR_PAIR(4));
    attron ($$self[0],A_BOLD);
    addstr ($$self[0],"["); 
    attroff ($$self[0],A_BOLD);
    attron ($$self[0],COLOR_PAIR(3));
    ($$self[4]) && addch ($$self[0],ACS_RARROW);
    ($$self[4]) || addstr ($$self[0]," ");
    attron ($$self[0],COLOR_PAIR(4));
    attron ($$self[0],A_BOLD);
    addstr ($$self[0],"]");    
    attroff ($$self[0],A_BOLD);
    attron ($$self[0],COLOR_PAIR(3));
    addstr ($$self[0]," $$self[1]");
}

sub display {
    my $self=shift;
    $self->place;
    refresh ($$self[0]);
}

sub rfsh {			# Refreshes display of your check box
    my $self = shift;
    move ($$self[0],$$self[3],$$self[2]+1); 
    attron ($$self[0],COLOR_PAIR(3));
    ($$self[4]) && addch ($$self[0],ACS_RARROW);
    ($$self[4]) || addstr ($$self[0]," ");
    move ($$self[0],$$self[3],$$self[2]+1); 
    refresh ($$self[0]);
}

sub activate {			# Makes checkbox active
    my $self = shift;		# $foo->activate;
    my @key;
    $self->rfsh;
    # refresh_cursor();

    while (@key = PV::getkey()) {

	if ($key[1]==7) {	# UpArrow
	    return 1;
	}
	elsif ($key[1]==8) {	# DnArrow
	    return 2;
	}
	elsif ($key[1]==9) {	# RightArrow
	    return 3;
	}
	elsif ($key[1]==10) {	# LeftArrow
	    return 4;
	}
	elsif ($key[1]==18) {	# Help
	    return 5;
	}
	elsif ($key[1]==19) {	# Menu
	    return 6;
	}
	elsif (($key[0] eq "\t") && ($key[1]==200)) { 
	    return 7;
	}

	elsif (($key[0] eq ' ') && ($key[1]==200)) {
	    $self->select;
	}
	$self->rfsh;
	# refresh_cursor();

    }
}

sub select {			# Toggles checkbox status
    my $self = shift;
    $$self[4] = ($$self[4] ? 0 : 1);
}

sub stat {			# Returns status of checkbox
    my $self = shift;		# $bar = $foo->status;
    return $$self[4];
}

package PV::Radio;
use Curses;
@ISA = (PV::Checkbox);

sub new {			# Creates your basic radio button
    my $type = shift;		# $foo = new PV::Radio (Label,x,y,stat);
    my @params = (stdscr,@_,0);
    my $self = \@params;
    bless $self;
    return $self;
}

sub place {			# Displays a radio button
    my $self = shift;		# $foo->display;
    move ($$self[0],$$self[3],$$self[2]); 
    attron ($$self[0],COLOR_PAIR(4));
    attron ($$self[0],A_BOLD);
    addstr ($$self[0],"(");
    attroff ($$self[0],A_BOLD);
    attron ($$self[0],COLOR_PAIR(3));
    ($$self[4]) && addch ($$self[0],ACS_DIAMOND);
    ($$self[4]) || addstr ($$self[0]," ");
    attron ($$self[0],COLOR_PAIR(4));
    attron ($$self[0],A_BOLD);
    addstr ($$self[0],")");
    attroff ($$self[0],A_BOLD);
    attron ($$self[0],COLOR_PAIR(3));
    addstr ($$self[0]," $$self[1]");
}

sub display {
    my $self=shift;
    $self->place;
    refresh ($$self[0]);
}

sub rfsh {			# Refreshes display of your check box
    my $self = shift;
    move ($$self[0],$$self[3],$$self[2]+1); 
    attron ($$self[0],COLOR_PAIR(3));
    ($$self[4]) && addch ($$self[0],ACS_DIAMOND);
    ($$self[4]) || addstr ($$self[0]," ");
    move ($$self[0],$$self[3],$$self[2]+1); 
    refresh ($$self[0]);
}

sub group {			# Puts the button in a group
    my $self = shift;		# Should not be called from outside
    $$self[6] = shift;
}

sub select {			# Turn radio button on
    my $self = shift;
    unless ($$self[4]) {
	$$self[6]->blank if $$self[6];
	$$self[4] = 1;
	$$self[6]->rfsh;
    }
}

sub unselect {			# Turn radio button off
    my $self = shift;
    $$self[4] = 0;
}

package PV::RadioG;
use Curses;
	    
sub new {			# Creates your basic radio button group
    my $type = shift;		# $foo = new PV::RadioG (rb1, rb2, rb3...)
    my @params = @_;		# where rbn is of class PV::Radio
    my $self = \@params;
    my $i;
    bless $self;
    foreach $i (@$self) {
	($i->group($self));
    }
    return $self;
}

sub place {
    my $self = shift;
    my $i;
    foreach $i (@$self) {
	$i->display;
    }
}

sub display {
    my $self=shift;
    $self->place;
}

sub rfsh {
    my $self = shift;
    my $i;
    foreach $i (@$self) {
	$i->rfsh;
    }
}

sub blank {			# Unchecks all buttons in the group
    my $self = shift;
    my $i;
    foreach $i (@$self) {
	$i->unselect;
    }
}
    
sub stat {			# Returns label of selected radio button
    my $self = shift;
    my $i;
    foreach $i (@$self) {
	($i->stat) && (return $$i[0]);
    }
    return undef;
}

package PV::Pushbutton;
use Curses;

sub new {			# Creates a basic pushbutton
    my $type = shift;		# PV::Pushbutton ("Label",x1,y1);
    my @params= (stdscr,@_);
    my $self = \@params;
    bless $self;
}

sub place {
    my $self=shift;
    PV::mybox(@$self[2..3],$$self[2]+length($$self[1])+3,$$self[3]+2,1,0,$$self[0]);
    attron ($$self[0],COLOR_PAIR(1));
    move ($$self[0],$$self[3]+1,$$self[2]+2);
    addstr ($$self[0],$$self[1]);
}    

sub display {
    my $self=shift;
    $self->place;
    refresh ($$self[0]);
}

sub press {
    my $self=shift;
    PV::mybox(@$self[2..3],$$self[2]+length($$self[1])+3,$$self[3]+2,0,0,$$self[0]);
    attron ($$self[0],COLOR_PAIR(1));
    move ($$self[0],$$self[3]+1,$$self[2]+2);
    addstr ($$self[0],$$self[1]);
    refresh ($$self[0]);
}

sub active {
    my $self=shift;
    attron ($$self[0],COLOR_PAIR(6));
    attron ($$self[0],A_BOLD);
    move ($$self[0],$$self[3]+1,$$self[2]+2);
    addstr ($$self[0],$$self[1]);
    attroff ($$self[0],A_BOLD);
    refresh ($$self[0]);
}

sub activate {
    my $self=shift;
    $self->active;
    while (@key = PV::getkey()) {

	if ($key[1]==7) {	# UpArrow
	    $self->display;
	    return 1;
	}
	elsif ($key[1]==8) {	# DnArrow
	    $self->display;
	    return 2;
	}
	elsif ($key[1]==9) {	# RightArrow
	    $self->display;
	    return 3;
	}
	elsif ($key[1]==10) {	# LeftArrow
	    $self->display;
	    return 4;
	}
	elsif ($key[1]==18) {	# Help
	    $self->display;
	    return 5;
	}
	elsif ($key[1]==19) {	# Menu
	    $self->display;
	    return 6;
	}
	elsif (($key[0] eq "\t") && ($key[1]==200)) { 
	    $self->display;
	    return 7;
	}

	elsif (($key[0] =~ /[ \n]/) && ($key[1]==200)) {
	    $self->press;
	    return 8;
	}
    }
}

package PV::Cutebutton;
use Curses;
@ISA = (PV::Pushbutton);

sub new {			# A smaller, cuter pushbutton
    my $type = shift;		# PV::Pushbutton ("Label",x1,y1);
    my @params= (stdscr,@_);
    my $self = \@params;
    bless $self;
}

sub place {
    my $self=shift;
    attron ($$self[0],COLOR_PAIR(7));
    addstr ($$self[0],$$self[3],$$self[2],"  ".$$self[1]." ");
    attron ($$self[0],COLOR_PAIR(3));
    addch ($$self[0],ACS_VLINE);
    attron ($$self[0],COLOR_PAIR(4));
    attron ($$self[0],A_BOLD);
    move ($$self[0],$$self[3]+1,$$self[2]);
    addch ($$self[0],ACS_LLCORNER);
    attroff ($$self[0],A_BOLD);
    attron ($$self[0],COLOR_PAIR(3));
    hline ($$self[0],ACS_HLINE, length($$self[1])+2);
    addch ($$self[0],$$self[3]+1,$$self[2]+length($$self[1])+3,ACS_LRCORNER);
}    

sub display {
    my $self=shift;
    $self->place;
    refresh ($$self[0]);
}

sub press {
    my $self=shift;
    attron ($$self[0],COLOR_PAIR(3));
    addch ($$self[0],$$self[3],$$self[2],ACS_ULCORNER);
    hline ($$self[0],ACS_HLINE,length($$self[1])+2);
    attron ($$self[0],COLOR_PAIR(4));
    attron ($$self[0],A_BOLD);
    addch ($$self[0],$$self[3],$$self[2]+length($$self[1])+3,ACS_URCORNER);
    move ($$self[0],$$self[3]+1,$$self[2]); 
    attron ($$self[0],COLOR_PAIR(3));
    attroff ($$self[0],A_BOLD);
    addch ($$self[0],ACS_VLINE);
    attron ($$self[0],COLOR_PAIR(7));
    addstr ($$self[0]," ".$$self[1]."  ");
    refresh ($$self[0]);
}

sub active {
    my $self=shift;
    attron ($$self[0],COLOR_PAIR(5));
    attron ($$self[0],A_BOLD);
    attron ($$self[0],A_REVERSE);
    move ($$self[0],$$self[3],$$self[2]+2);
    addstr ($$self[0],$$self[1]);
    attroff ($$self[0],A_BOLD);
    attroff ($$self[0],A_REVERSE);
    refresh ($$self[0]);
}

package PV::Plainbutton;
use Curses;
@ISA = (PV::Pushbutton);

sub new {			# A minimal pushbutton
    my $type = shift;		# PV::Pushbutton ("Label",x1,y1);
    my @params= (stdscr,@_);
    my $self = \@params;
    bless $self;
}

sub place {
    my $self=shift;
    attron ($$self[0],COLOR_PAIR(4));
    attron ($$self[0],A_BOLD);
    move ($$self[0],$$self[3],$$self[2]);
    addstr ($$self[0],$$self[1]);
    attroff ($$self[0],A_BOLD);
}    

sub display {
    my $self=shift;
    $self->place;
    refresh ($$self[0]);
}

sub press {
}

sub active {
    my $self=shift;
    attron ($$self[0],COLOR_PAIR(5));
    attron ($$self[0],A_BOLD);
    attron ($$self[0],A_REVERSE);
    move ($$self[0],$$self[3],$$self[2]);
    addstr ($$self[0],$$self[1]);
    refresh ($$self[0]);
    attroff ($$self[0],A_BOLD);
    attroff ($$self[0],A_REVERSE);
}

package PV::_::SListbox;
use Curses;

sub new {			# Creates a superclass list box
    my $type = shift;		# PV::_::SListbox (Head,top,x1,y1,x2,y2,list)
    my $head = shift;
    my @params = (stdscr,$head,0,@_);	# where list is (l1,s1,l2,s2,...)
    my $self = \@params;	# Do not use from outside
    bless $self;
}

sub place {
    my $self = shift;
    my ($top,$x1,$y1,$x2,$y2) = @$self[2..6];
    $self->draw_border;
    my $i = shift;
    $i *= 2;
    $x1++; $y1++;
    while (($y1 < $y2) && ($i+7 < $#$self)) {
	($$self[8+$i]) && ($self->selected($y1,$i));
	($$self[8+$i]) || ($self->unselected($y1,$i));
	$y1++;
	$i += 2;
    }
}

sub display {
    my $self=shift;
    $self->place;
    refresh ($$self[0]);
}

sub rfsh {
    my $self = shift;
    my ($top,$x1,$y1,$x2,$y2) = @$self[2..6];
    my $i = shift;
    unless ($i==$top) {
	$$self[2]=$i;
	$i *= 2;
	$x1++; $y1++;
	while (($y1 < $y2) && ($i+7 < $#$self)) {
	    ($$self[8+$i]) && ($self->selected($y1,$i));
	    ($$self[8+$i]) || ($self->unselected($y1,$i));
	    $y1++;
	    $i += 2;
	}
    }
    refresh ($$self[0]);
}

sub unhighlight {
    my $self = shift;
    my ($ypos,$i) = @_;
    ($$self[8+$i]) && ($self->selected($ypos,$i));
    ($$self[8+$i]) || ($self->unselected($ypos,$i));
    refresh ($$self[0]);
}

sub highlight {
    my $self = shift;
    my $ypos = shift;
    my $i = shift;
    my ($x1,$x2) = @$self[3,5];
    $x1++;
    attron ($$self[0],COLOR_PAIR(5));
    attron ($$self[0],A_BOLD);
    attron ($$self[0],A_REVERSE);
    move ($$self[0],$ypos,$x1+1);
    addstr ($$self[0],substr ($$self[7+$i],0,$x2-$x1-2).
		 " " x 
		 ($x2-$x1-2-length(substr($$self[7+$i],0,$x2-$x1-2))));
    attroff ($$self[0],A_BOLD);
    attroff ($$self[0],A_REVERSE);
    refresh ($$self[0]);
}

sub selected {
    my $self = shift;
    my $ypos = shift;
    my $i = shift;
    $self->unselected($ypos,$i);
}

sub reset {
    my $self = shift;
    my $i;
    for ($i=8; $i <= $#$self; $i +=2) {
	$$self[$i] = 0;
    }
    $self->rfsh(0);
}

sub stat {
    my $self = shift;
    my $i;
    my @returnlist = ();
    for ($i=8; $i <= $#$self; $i +=2) {
	($$self[$i]) && (@returnlist = (@returnlist,$$self[$i-1]));
    }
    $self->reset;
    return @returnlist;
}

sub done {
    my $self = shift;
    my $i = shift;
    $$self[$i*2+8]=1;
    $self->rfsh(0);
}

sub deactivate {
    my $self = shift;
    $self->reset();
}

sub unselected {
    my $self = shift;
    my $ypos = shift;
    my $i = shift;
    my ($x1,$x2) = @$self[3,5];
    $x1++;
    attron ($$self[0],COLOR_PAIR(3));
    move ($$self[0],$ypos,$x1+1);
    addstr ($$self[0],substr ($$self[7+$i],0,$x2-$x1-2).
		 " " x 
		 ($x2-$x1-2-length(substr($$self[7+$i],0,$x2-$x1-2))));
}

sub activate {
    my $self = shift;
    my ($x1,$y1,$x2,$y2) = @$self[3..6];
    my $i = 0;
    my @key;
    $x1++; $y1++;
    my $ypos=$y1;
    $self->rfsh($i);
    $self->highlight($y1,$i*2);
    while (@key = PV::getkey()) {

	if ($key[1]==18) {	# Help
	    $self->unhighlight($ypos,$i*2);
	    $self->deactivate();
	    return 5;
	}
	elsif ($key[1]==19) {	# Menu
	    $self->unhighlight($ypos,$i*2);
	    $self->deactivate();
	    return 6;
	}
	elsif ($key[1]==9) {	# RightArrow
	    $self->unhighlight($ypos,$i*2);
	    $self->deactivate();
	    return 3;
	}
	elsif ($key[1]==10) {	# LeftArrow
	    $self->unhighlight($ypos,$i*2);
	    $self->deactivate();
	    return 4;
	}
	elsif (($key[0] eq "\t") && ($key[1]==200)) { 
	    $self->unhighlight($ypos,$i*2);
	    $self->deactivate();
	    return 7;
	}
        elsif (($key[0] eq "\n") && ($key[1] == 200)) {
	    $self->unhighlight($ypos,$i*2);
	    $self->done($i);
	    return 8;		
	}
	elsif (($key[0] eq " ") && ($key[1] == 200)) {
	    $self->select($i);
	    $self->highlight($ypos,$i*2);
	}
	elsif (($key[1] == 7) && ($i != 0)) { # Up
	    ($ypos == $y1) || do {$self->unhighlight($ypos,$i*2); $ypos--};
	    $i--;
	    $self->rfsh($i-$ypos+$y1);
	    $self->highlight($ypos,$i*2);
	}
	elsif (($key[1] == 8) && (($i*2+9) < $#$self)) { # Down
	    ($ypos == $y2-1) || do {$self->unhighlight($ypos,$i*2); $ypos++};
	    $i++;
	    $self->rfsh($i-$ypos+$y1);
	    $self->highlight($ypos,$i*2);
	}
    }
}

sub draw_border {
    my $self = shift;
    PV::mybox(@$self[3..6],0,1,$$self[0]);
    attron ($$self[0],COLOR_PAIR(4));
    attron ($$self[0],A_BOLD);
    move ($$self[0],$$self[4],$$self[3]);
    addstr ($$self[0],$$self[1]);
    attroff ($$self[0],A_BOLD);
}

sub select {
}

package PV::Listbox;
use Curses;
@ISA = (PV::_::SListbox);

sub new {			# Basic single selection listbox
    my $type = shift;		# PV::Listbox (Head,x1,y1,x2,y2,list)
    my @params = @_;		# where list is (l1,s1,l2,s2,...)
    my $self = new PV::_::SListbox(@params);
    bless $self;
}

package PV::Mlistbox;
use Curses;
@ISA = (PV::_::SListbox);

sub new {			# A multiple selection listbox
    my $type = shift;		# PV::Mlistbox (Head,x1,y1,x2,y2,list)
    my @params = @_;		# where list is (l1,s1,l2,s2,...)
    my $self = new PV::_::SListbox(@params);
    bless $self;
}

sub select {
    my $self = shift;
    my $i = shift;
    if ($$self[8+$i*2]) {
	$$self[8+$i*2] = 0;
    }
    else {
	$$self[8+$i*2] = 1;
    }
}

sub selected {
    my $self = shift;
    my $ypos = shift;
    my $i = shift;
    my ($x1,$x2) = @$self[3,5];
    $x1++;
    attron ($$self[0],COLOR_PAIR(4));
    attron ($$self[0],A_BOLD);
    move ($$self[0],$ypos,$x1+1);
    addstr ($$self[0],substr ($$self[7+$i],0,$x2-$x1-2).
		 " " x 
		 ($x2-$x1-2-length(substr($$self[7+$i],0,$x2-$x1-2))));
    attroff ($$self[0],A_BOLD);
}

sub highlight {
    my $self = shift;
    my $ypos = shift;
    my $i = shift;
    my ($x1,$x2) = @$self[3,5];
    $x1++;
    attron ($$self[0],COLOR_PAIR(5));
    $$self[8+$i] && attron ($$self[0],A_BOLD);
    attron ($$self[0],A_REVERSE);
    move ($$self[0],$ypos,$x1+1);
    addstr ($$self[0],substr ($$self[7+$i],0,$x2-$x1-2).
		 " " x 
		 ($x2-$x1-2-length(substr($$self[7+$i],0,$x2-$x1-2))));
    attroff ($$self[0],A_BOLD);
    attroff ($$self[0],A_REVERSE);
    refresh ($$self[0]);
}

sub deactivate {
    my $self = shift;
    $self->rfsh();
}

sub done {
    my $self = shift;
    $self->rfsh();
}

package PV::_::Pulldown;
use Curses;
@ISA = (PV::_::SListbox);

sub new {			# A pulldown menu box. Used by PV::Menubar
    my $type = shift;		# Don't use from outside
    my @params = (@_);
    my $self = new PV::_::SListbox(@params);
    bless $self;
}

sub draw_border {
    my $self = shift;
    PV::mybox(@$self[3..6],1,0,$$self[0]);
    move ($$self[0],$$self[4],$$self[3]);
    attron ($$self[0],COLOR_PAIR(2));
    attron ($$self[0],A_BOLD);
    addch ($$self[0],($$self[$#$self] == 1) ? ACS_VLINE : ACS_URCORNER);
    attroff ($$self[0],A_BOLD);
    attron ($$self[0],COLOR_PAIR(1));
    addstr ($$self[0]," " x ($$self[5]-$$self[3]-1));
    move ($$self[0],$$self[4],$$self[5]);
    addch ($$self[0],ACS_ULCORNER);
}

sub unselected {
    my $self = shift;
    my $ypos = shift;
    my $i = shift;
    my ($x1,$x2) = @$self[3,5];
    $x1++;
    attron ($$self[0],COLOR_PAIR(5));
    move ($$self[0],$ypos,$x1+1);
    addstr ($$self[0],substr ($$self[7+$i],0,$x2-$x1-2).
		 " " x 
		 ($x2-$x1-2-length(substr($$self[7+$i],0,$x2-$x1-2))));
}

sub activate {
    my $self=shift;
    touchwin ($$self[0]);
    $self->display();
    my $ret=$self->PV::_::SListbox::activate();
    touchwin (stdscr);
    refresh(stdscr);
    return ($ret,$self->stat());
}

package PV::Menubar;		
use Curses;

sub new {			# A menu bar with pulldowns
    my $type=shift;		# new PV::Menubar(Head,width,depth,l,0,l,0,l,0,l,0,l);
    my @params=@_;
    my $pulldown = new PV::_::Pulldown ($params[0],0,0,$params[1],$params[2],
					@params[3..$#params],1);
    my $panel = newwin ($params[2]+1,$params[1]+1,2,1);
    $$pulldown[0] = $panel;
    my $self=[$pulldown,3];
    bless $self;
}

sub add {			# Add a pulldown to the menubar
    my $self=shift;		# $foo->add(Head,width,depth,l,0,l,0,l,0,l,0,l);
    my @params=@_;
    my $pulldown = new PV::_::Pulldown ($params[0],0,0,$params[1],$params[2],
					@params[3..$#params],0);
    my $startoff = $$self[$#$self] + length ($$self[$#$self-1][1]) + 4;
    my $panel = newwin ($params[2]+1,$params[1]+1,2,$startoff-2);
    $$pulldown[0] = $panel;
    $$self[$#$self+1]=$pulldown;
    $$self[$#$self+1]=$startoff;
}

sub highlight {
    my $self=shift;
    my $i=shift;
    move (1,$$self[$i*2+1]);
    attron (COLOR_PAIR(7));
    attron (A_BOLD);
    attron (A_REVERSE);
    addstr ($$self[$i*2][1]);
    attroff (A_BOLD);
    attroff (A_REVERSE);
    refresh();
}

sub unhighlight {
    my $self=shift;
    my $i=shift;
    move (1,$$self[$i*2+1]);
    attron (COLOR_PAIR(1));
    addstr ($$self[$i*2][1]);
    refresh();
}

sub activate {
    my $self=shift;
    my $i=0;
    my @key;
    my @ret;
    $self->highlight($i);
    while (@key = PV::getkey()) {

	if ($key[1]==18) {	# Help
	    $self->unhighlight($i);
	    return 5;
	}
	elsif ($key[1]==9) {	# RightArrow
	    $$self[$i*2]->reset();
	    $self->unhighlight($i);
	    $i = (($i*2+1==$#$self) ? 0 : $i+1);
	    $self->highlight($i);
	}
	elsif ($key[1]==10) {	# LeftArrow
	    $$self[$i*2]->reset();
	    $self->unhighlight($i);
	    $i = ($i==0 ? ($#$self-1)/2 : $i-1);
	    $self->highlight($i);
	}
	elsif (($key[0] eq "\t") && ($key[1]==200)) { 
	    $self->unhighlight($i);
	    return 7;
	}
        elsif ((($key[0] eq "\n") && ($key[1] == 200)) || ($key[1] == 8))  {
	    while (@ret = ($$self[$i*2]->activate())) {
		if ($ret[0]==3) {
		    $$self[$i*2]->reset();
		    $self->unhighlight($i);
		    $i = (($i*2+1==$#$self) ? 0 : $i+1);
		    $self->highlight($i);
		}
		elsif ($ret[0]==4) {
		    $$self[$i*2]->reset();
		    $self->unhighlight($i);
		    $i = ($i==0 ? ($#$self-1)/2 : $i-1);
		    $self->highlight($i);
		}
		else {
		    last;
		}
	    }
	    refresh;
	    if ($ret[0] == 5) {
		$self->unhighlight($i);
		return 5;
	    }
	    elsif ($ret[0] == 8) {
		$self->unhighlight($i);
		return (8,$$self[$i*2][1].":".$ret[1]);
	    }
	}
    }
}

sub place {
    my $self=shift;
    my ($i);
    PV::mybox (1,0,78,2,1,0,stdscr);
    for ($i=0; $i <= ($#$self-1)/2; $i++) {
	move (1,$$self[$i*2+1]);
	addstr ($$self[$i*2][1]);
    }
}

sub display {
    my $self=shift;
    $self->place;
    refresh();
}

package PV::Entryfield;
use Curses;

sub new {			# Creates your basic text entry field
    my $type = shift;		# new PV::Entryfield(x,y,len,start,label,value);
    my @params = (stdscr,@_);
    my $self = \@params;
    bless $self;
}

sub place {
    my $self = shift;
    my $start = shift;
    my ($x,$y,$len,$max,$label,$value)=@$self[1..6];
    move ($$self[0],$y,$x); 
    attron ($$self[0],COLOR_PAIR(3));
    addstr ($$self[0],$label." "); 
    attron ($$self[0],COLOR_PAIR(6));
    attron ($$self[0],A_BOLD);
    addstr ($$self[0]," ");
    addstr ($$self[0],substr($value,$start,$len)); 
    addstr ($$self[0],"." x ($len - length(substr($value,$start,$len)))); 
    addstr ($$self[0]," ");
    attroff ($$self[0],A_BOLD);
}

sub display {
    my $self=shift;
    $self->place;
    refresh ($$self[0]);
}

sub rfsh {
    my $self = shift;
    my $start = shift;
    my $i=shift;
    my ($x,$y,$len,$oldstart,$label,$value)=@$self[1..6];
    if ($oldstart == $start) {
        move ($$self[0],$y,$x+length($label)+2+$i-$start); 
	attron ($$self[0],COLOR_PAIR(6));
	attron ($$self[0],A_BOLD);
	addstr ($$self[0],substr($value,$i,$len-($i-$start))); 
	addstr ($$self[0],"." x ($len-($i-$start)-length(substr($value,$i,$len)))); 
	attroff ($$self[0],A_BOLD);
    }
    else {
	$$self[4]=$start;
	move ($$self[0],$y,$x+length($label)+2); 
	attron ($$self[0],COLOR_PAIR(6));
	attron ($$self[0],A_BOLD);
	addstr ($$self[0],substr($value,$start,$len)); 
	addstr ($$self[0],"." x ($len - length(substr($value,$start,$len)))); 
	attroff ($$self[0],A_BOLD);
    }
}

sub activate {			# Makes entryfield active
    my $self = shift;
    my $OVSTRK_MODE=0;
    my ($x,$y,$len,$max,$label)=@$self[1..5];
    my $i=0;
    $x += length($label)+2;
    my $start=0; my $savestart=0;
    my $jump=(($len % 2) ? ($len+1)/2 : $len/2);
    $self->rfsh($start,$i);
    move ($$self[0],$y,$x);
    refresh ($$self[0]);
    while (@key = PV::getkey()) {

	if ($key[1]==7) {	# UpArrow
	    $self->rfsh(0,0);
	    refresh ($$self[0]);
	    return 1;
	}
	elsif ($key[1]==8) {	# DnArrow
	    $self->rfsh(0,0);
	    refresh ($$self[0]);
	    return 2;
	}
	elsif ($key[1]==18) {	# Help
	    $self->rfsh(0,0);
	    refresh ($$self[0]);
	    return 5;
	}
	elsif ($key[1]==19) {	# Menu
	    $self->rfsh(0,0);
	    refresh ($$self[0]);
	    return 6;
	}

	($key[1]==11) && do {	# Backspace
	    if ($i) {
		$i--;
		substr ($$self[6],$i,1) = "";
		($i<$start) && ($start -= $jump);
		($start <0) && ($start = 0);
		$self->rfsh($start,$i);
		move ($$self[0],$y,$x+$i-$start);
		refresh ($$self[0]);
	    }
	};
	($key[1]==200) && do {
	    if ($key[0] =~ /[\n\r\t\f]/) {
		($key[0] eq "\t") && do {
		    $self->rfsh(0,0);
		    refresh ($$self[0]);
		    return 7;
		};
		(($key[0] eq "\n") || ($key[0] eq "\r")) && do {
		    $self->rfsh(0,0);
		    refresh ($$self[0]);
		    return 8;
		};
		($key[0] eq "\f") && do {

		};
	    }
	    else {
		substr ($$self[6],$i,$OVSTRK_MODE) = $key[0];
		($i-$start >= $len) && ($start += $jump);
		$self->rfsh($start,$i);
		$i++;
	        move ($$self[0],$y,$x+$i-$start); 
		refresh ($$self[0]);
	    }
	};
	($key[1]==1) && do {	# Home
	    ($start) && ($self->rfsh(0,0));
	    $i=0; $start=0;
	    move ($$self[0],$y,$x);
	    refresh ($$self[0]);
	};
	($key[1]==2) && do {	# Insert
	    $OVSTRK_MODE = ($OVSTRK_MODE ? 0 : 1);
	};
	($key[1]==3) && do {	# Del
	    if ($i < length($$self[6])) {
		substr ($$self[6],$i,1) = "";
		$self->rfsh($start,$i);
    	        move ($$self[0],$y,$x+$i-$start); 
		refresh ($$self[0]);
	    }
	};
	($key[1]==4) && do {	# End
	    $i=length($$self[6]); 
	    $savestart=$start;
	    ($start+$len <= length($$self[6])) && 
	     (($start=$i-$len+1) < 0) && ($start = 0);
	    ($savestart != $start) && ($self->rfsh($start,$i));
	    move ($$self[0],$y,$x+$i-$start); 
	    refresh ($$self[0]);
	};
	($key[1]==9) && do {	# RightArrow
	    if ($i < length($$self[6])) {
		$i++;
		$savestart=$start;
		($i-$start >= $len) && ($start += $jump);
		($savestart != $start) && ($self->rfsh($start,$i));
	        move ($$self[0],$y,$x+$i-$start);
		refresh ($$self[0]);
	    }
	};
	($key[1]==10) && do {	# LeftArrow
	    if ($i) {
		$i--;
		$savestart=$start;
		($i<$start) && ($start -= $jump);
		($start <0) && ($start = 0);
		($savestart != $start) && ($self->rfsh($start,$i));
	        move ($$self[0],$y,$x+$i-$start); 
		refresh ($$self[0]);
	    }
	};
    }
}

sub stat {
    my $self = shift;
    return $$self[6];
}

package PV::Password;
use Curses;
@ISA = (PV::Entryfield);

sub new {			# Creates your basic hidden text entry field
    my $type = shift;		# new PV::Entryfield(x,y,len,max,label,value);
    my @params = (stdscr,@_);
    my $self = \@params;
    bless $self;
}

sub place {
    my $self = shift;
    my $start = shift;
    my ($x,$y,$len,$max,$label,$value)=@$self[1..6];
    move ($$self[0],$y,$x); 
    attron ($$self[0],COLOR_PAIR(3));
    addstr ($$self[0],$label." "); 
    attron ($$self[0],COLOR_PAIR(6));
    attron ($$self[0],A_BOLD);
    addstr ($$self[0]," ");
    addstr ($$self[0],"*" x (length(substr($value,$start,$len)))); 
    addstr ($$self[0],"." x ($len - length(substr($value,$start,$len)))); 
    addstr ($$self[0]," ");
    attroff ($$self[0],A_BOLD);
}

sub display {
    my $self=shift;
    $self->place;
    refresh ($$self[0]);
}

sub rfsh {
    my $self = shift;
    my $start = shift;
    my $i=shift;
    my ($x,$y,$len,$oldstart,$label,$value)=@$self[1..6];
    if ($oldstart == $start) {
        move ($$self[0],$y,$x+length($label)+2+$i-$start); 
	attron ($$self[0],COLOR_PAIR(6));
	attron ($$self[0],A_BOLD);
	addstr ($$self[0],"*" x (length (substr($value,$i,$len-($i-$start))))); 
	addstr ($$self[0],"." x ($len-($i-$start)-length(substr($value,$i,$len)))); 
	attroff ($$self[0],A_BOLD);
    }
    else {
	$$self[4]=$start;
	move ($$self[0],$y,$x+length($label)+2); 
	attron ($$self[0],COLOR_PAIR(6));
	attron ($$self[0],A_BOLD);
	addstr ($$self[0],"*" x (length(substr($value,$start,$len)))); 
	addstr ($$self[0],"." x ($len - length(substr($value,$start,$len)))); 
	attroff ($$self[0],A_BOLD);
    }
    refresh ($$self[0]);
}

package PV::Combobox;
use Curses;

sub new {			# A basic combo-box
}

package PV::Viewbox;		
use Curses;

sub new {			# A readonly text viewer
    my $type=shift;		# PV::Viewbox (x1,y1,x2,y2,text,top);
    my @params=(stdscr,@_,[],[]);
    my $self=\@params;
    $$self[5]=~s/[\r\0]//g;	# Strip nulls & DOShit.
    $$self[5]=~s/\t/        /g;	# TABs = 8 spaces.
    $$self[5].="\n";
    my $text = $$self[5];
    $text=~s/\n/\n\t/g;
    @{$$self[7]}=split("\t",$text);
    @{$$self[8]}=();
    bless $self;
}

sub place {
    my $self=shift;
    my ($x1,$y1,$x2,$y2,$text,$start)=@$self[1..6];
    my $lines=$y2-$y1-2;
    my $i=0;
    $y1++;
    PV::mybox(@$self[1..4],0,1,$$self[0]);
    $self->rfsh(1);
}

sub display {
    my $self=shift;
    $self->place;
    refresh ($$self[0]);
}

sub rfsh {
    my $self=shift;
    my $display=shift;
    ($$self[6]>($#{$$self[7]}-$$self[4]+$$self[2]+2)) && 
	($$self[6]=$#{$$self[7]}-$$self[4]+$$self[2]+2);
    ($$self[6]<0) && ($$self[6]=0);
    my ($x1,$y1,$x2,$y2,$text,$start)=@$self[1..6];
    my $lines=$y2-$y1-2;
    my $l;
    my $i=0;
    $y1++; my $len=0;
    attron ($$self[0],COLOR_PAIR(3));
    foreach (@{$$self[7]}[$start..$start+$lines]) {
	unless ($$self[8][$i] eq $_) {
	    move ($$self[0],$y1+$i,$x1+2);
  	    $l=$_;
	    $len=length ($$self[8][$i]);
	    $$self[8][$i] = $l;
	    chop ($l);
	    (length($l) > $x2-$x1-3) && ($l=substr($l,0,$x2-$x1-3));
	    addstr ($$self[0],$l); 
  	    if (length($l) < $x2-$x1-3) {
		addstr ($$self[0]," " x ($x2-$x1-3 - length ($l)));
	    }
	}
    $i++;
    }
    $self->statusbar;
    ($display) || (refresh ($$self[0]));
}

sub statusbar {
}

sub activate {			# Makes viewer active
    my $self = shift;
    my ($x1,$y1,$x2,$y2,$text,$start)=@$self[1..6];
    $self->rfsh;
    move ($$self[0],$y2-1,$x2-1);
    refresh ($$self[0]);
    while (@key = PV::getkey()) {

	if ($key[1]==18) {	# Help
	    $self->rfsh;
	    return 5;
	}
	elsif ($key[1]==19) {	# Menu
	    $self->rfsh;
	    return 6;
	}
	($key[1]==200) && do {
	    if ($key[0] =~ /[\r\t\f]/) {
		($key[0] eq "\t") && do {
		    $self->rfsh;
		    return 7;
		};
	    }
	};

	($key[1]==1) && do {	# Home
	    $$self[6]=0;
	    $self->rfsh;
	};
	($key[1]==4) && do {	# End
	    $$self[6]=$#{$$self[7]}-$y2+$y1+2;
	    $self->rfsh;
	};
	($key[1]==5) && do {	# PgUp
	    $$self[6]-=$y2-$y1-2;
	    $self->rfsh;
	};
	($key[1]==6) && do {	# PgDown
	    $$self[6]+=$y2-$y1-2;
	    $self->rfsh;
	};
	($key[1]==7) && do {	# UpArrow
	    $$self[6]--;
	    $self->rfsh;
	};
	($key[1]==8) && do {	# DownArrow
	    $$self[6]++;
	    $self->rfsh;
	};
    }
}

package PV::Editbox;
use Curses;

sub new {			# More or less a complete editor
    my $type=shift;		# PV::Editbox (x1,y1,x2,y2,m,text,index,top);
    my @params=(stdscr,@_,[],[],0);
    my $self=\@params;
    $$self[6]=~s/[\r\0]//g;	# Strip nulls & DOShit.
    $$self[6]=~s/\t/        /g;	# TABs = 8 spaces.
    $$self[6].="\n";
    bless $self;
    $self->justify(1);
    return $self;
}

sub place {
    my $self=shift;
    my ($x1,$y1,$x2,$y2,$margin,$text,$index,$start)=@$self[1..8];
    my $lines=$y2-$y1-2;
    my $i=0;
    $y1++;
    PV::mybox(@$self[1..4],0,1,$$self[0]);
    $self->rfsh(1);
}

sub display {
    my $self=shift;
    $self->place;
    refresh ($$self[0]);
}

sub statusbar {
}

sub rfsh {
    my $self=shift;
    my $display=shift;
    my ($x1,$y1,$x2,$y2,$margin,$text,$index,$start)=@$self[1..8];
    my @visible=@{$$self[10]};
    my $lines=$y2-$y1-2;
    my $i=0; my $l;
    $y1++;
    attron ($$self[0],COLOR_PAIR(3));
    foreach (@{$$self[9]}[$start..$start+$lines]) {
	unless ($visible[$i] eq $_) {
	    $$self[10][$i] = $_;
	    move ($$self[0],$y1+$i,$x1+2);
 	    $l=$_;
	    chop ($l);
	    addstr ($$self[0],$l); addstr ($$self[0]," " x (length ($visible[$i]) - length ($l)));
	}
    $i++;
    }
    $self->statusbar;
    ($display) || (refresh ($$self[0]));
}

sub process_key {
}

sub justify {
    my $self=shift;
    my $mode=shift;
    my ($x1,$y1,$x2,$y2,$margin,$text,$index)=@$self[1..7];
    my ($i,$j)=(0,0); my $line; my @text; my $ta; my $tb;
    my @textqq;
    substr ($text,$index,0)="\0";
    $text=~s/ *\n/\n/g;
    if ($mode) {
	$ta="";
	$tb="";
    }
    else {
	$mode=length($text);
	($ta,$tb)=split("\0",$text);
	$ta=$ta."\0";$tb="\0".$tb;
	$ta=~s/(.*)\n\s.*/$1/s; ($ta=~/\0/) && ($ta="");
	$tb=~s/.*?\n\s//s; ($tb=~/\0/) && ($tb="");
	$text=substr($text,length($ta),$mode-(length($ta)+length($tb)));
	$mode=0;
    }
    $text=~s/\n/\n\t/g;
    my @text=split("\t",$text);
    my $j=0;
    for ($i=0; $j<=$#text; $i++) {
	if (($text[$j] eq "\n") || ($text[$j] eq "\0\n")) {
	    $textqq[$i]=$text[$j];
	}
	else {
	    if (length($text[$j]) > $margin) {
		$line=$text[$j];
		$text[$j]=substr($text[$j],0,$margin);
		$text[$j]=~s/^(.*\s+)\S*$/$1/;
		$line=substr($line,length($text[$j])); 
		$line=~s/^\s*//;
		$text[$j]=~s/\s*$/\n/;
		if (($j==$#text) && ($line)) {
		    $text[$j+1]=$line;
		    @textqq[$i]=$text[$j];
		}
		elsif (($line) && 
		       ($text[$j+1]=~/^[\s\0]/)) {
		    $textqq[$i]=$text[$j];
		    $text[$j]=$line; $j--;
		}
		else {
		    $line=~s/\n$//;
		    $line=~s/(\S)$/$1 /;
		    $textqq[$i]=$text[$j];
		    $text[$j+1]=$line.$text[$j+1];
		}
	    }
	    elsif ((!$mode) && 
		   ($j < $#text) &&  
		   (length($text[$j])+
		    length ((split(" ",$text[$j+1]))[0]) < $margin) && 
		   ($text[$j+1] =~ /^[^\s\0]/)) { 

		chop ($text[$j]);
		($text[$j]=~/\s$/) || ($text[$j].=" ");
		$text[$j].=$text[$j+1];
		$textqq[$i]=$text[$j];
		$text[$j+1]=$text[$j];
		$i--;
	    }
	    else {
		$textqq[$i]=$text[$j];
	    }
	}
	$j++;
    }
    $text=join("",@textqq);
    $text=$ta.$text.$tb;
    $index=length((split("\0",$text))[0]);
    substr($text,$index,1)="";
    $$self[7]=$index;
    $$self[6]=$text;
    $text =~ s/\n/\n\t/g;
    @{$$self[9]}=split("\t",$text);
}

sub cursor {
    my $self=shift;
    my ($x1,$y1,$x2,$y2,$margin,$text,$index,$start)=@$self[1..8];
    my $textthis=substr($text,0,$index+1);
    my $col=0;
    my $line=($textthis =~ tr/\n//);
    if ($textthis=~/\n$/) {
	($line) && ($line--);
	$col++;
    }
    my $len=(length($$self[9][$line])-1);
    $col+=(length((split("\n",$textthis))[$line]));
    if ($line<$start) {
	$start=$line;
    }
    elsif ($line>=$start+$y2-$y1-1) {
	(($start=$line-$y2+$y1+2) <0) && ($start=0);
    }
    ($$self[8]!=$start) && do {
	$$self[8]=$start;
	$self->rfsh;
    };
    move ($$self[0],$y1+$line-$start+1,$col+$x1+1);
    return ($col,$line,$len);
}

sub linemove {
    my $self=shift;
    my $dir=shift;
    my $count=shift;
    my ($col, $line, $len) = $self->cursor;
    if ($dir) {
	($line+$count >$#{$$self[9]}) && ($count = $#{$$self[9]} - $line);
	if ($count) {
	    $$self[7]+=($len-$col+1);
	    (length ($$self[9][$line+$count]) < $col) && 
		($col=length ($$self[9][$line+$count]));
	    $$self[7]+=$col;
	    $count--;
	    while ($count) {
		$$self[7]+=length($$self[9][$count+$line]);
		$count--;
	    }
	}
    }
    elsif ($line) {
	($line - $count <0) && ($count = $line);
	$$self[7]-=($col+length($$self[9][$line-$count]));
	(length ($$self[9][$line-$count]) < $col) && 
	    ($col=length ($$self[9][$line-$count]));
	$$self[7]+=$col;
	$count--;
	while ($count) {
	    $$self[7]-=length($$self[9][$line-$count]);
	    $count--;
	}
    }
}

sub e_bkspc {
    my $self = shift;
    my ($col, $line, $len) = $self->cursor;
    if ($$self[7]) {
	$$self[7]--;
	if (substr ($$self[6],$$self[7],1) eq "\n") {
	    substr ($$self[6],$$self[7],1) = "";
	    $self->justify;
	}
	else {
	    substr ($$self[6],$$self[7],1) = "";
	    substr ($$self[9][$line],$col-2,1) = "";
	}
	$self->rfsh;
    }
}

sub e_del {
    my $self=shift;
    my ($col, $line, $len) = $self->cursor;
    unless ($$self[7]==length($$self[6])-1) {
	if (substr ($$self[6],$$self[7],1) eq "\n") {
	    substr ($$self[6],$$self[7],1) = "";
	    $self->justify;
	}
	else {
	    substr ($$self[6],$$self[7],1) = "";
	    substr ($$self[9][$line],$col-1,1) = "";
	}
	$self->rfsh;
    }
}

sub e_ins {
    my $self = shift;
    my $keystroke = shift;
    my ($col, $line, $len) = $self->cursor;
    if (substr ($$self[6],$$self[7],1) eq "\n") {
	substr ($$self[6],$$self[7],0) = $keystroke;
	substr($$self[9][$line],$col-1,0)=$keystroke;
    }
    else {
	substr ($$self[6],$$self[7],$$self[11]) = $keystroke;
	substr($$self[9][$line],$col-1,$$self[11])=$keystroke;
    }
    $$self[7]++;
    if ((length($$self[9][$line]) >= $$self[5]) || 
	($keystroke eq "\n")) {
	$self->justify;
    }
    $self->rfsh;
}

sub stat {
    my $self=shift;
    return $$self[6];
}

sub activate {			# Makes editbox active
    my $self = shift;
    my ($y1,$y2,$margin)=($$self[2],$$self[4],$$self[5]);
    my $exitcode;
    $self->rfsh;
    my ($col, $line, $len) = $self->cursor;
    refresh ($$self[0]);

    while (@key = PV::getkey()) {

	if ($key[1]==18) {	# Help
	    $self->rfsh;
	    return 5;
	}
	elsif ($key[1]==19) {	# Menu
	    $self->rfsh;
	    return 6;
	}
	else {			# Process key hook for subclasses
	    @exitcode = ($self->process_key (@key));
	    if ($exitcode[0] == 1) {
		$self->rfsh;
		return 8;
	    }
	    elsif ($exitcode[0] == 2) {
	    }
	    else {		# Now defaults for the editbox.
		if ($exitcode[0] == 3) {
		    @key = @exitcode[1..2];
		}

		($key[1]==11) && ($self->e_bkspc());
		(($key[1]==200) && ($key[0] eq "\t")) && do {$self->rfsh; return 7;};
		(($key[1]==200) && ($key[0] =~ /\r\f/)) && do {pv::redraw(); last;};
		($key[1]==200) && ($self->e_ins($key[0]));
		(($key[1]==2) || ($key[1]==21)) && ($$self[11] = ($$self[11] ? 0 : 1)); 
		(($key[1]==3) || (($key[0] eq "") && (!$key[1]))) && ($self->e_del());
		
		(($key[1]==1) || (($key[0] eq "") && (!$key[1]))) && do {	# Home
		    $$self[7]-=(($self->cursor)[0]-1);
		};
		(($key[1]==4) || (($key[0] eq "") && (!$key[1]))) && do {	# End
		    $$self[7]+=(($self->cursor)[2] - (($self->cursor)[0]-1));
		};
		(($key[1]==5) || ($key[1]==15)) && do {	# PgUp
		    $self->linemove (0,$y2-$y1-2);
		};
		(($key[1]==6) || (($key[0] eq "") && (!$key[1]))) && do {	# PgDown
		    $self->linemove (1,$y2-$y1-2);
		};
		(($key[1]==7) || (($key[0] eq "") && (!$key[1]))) && do {	# UpArrow
		    $self->linemove (0,1);
		};
		(($key[1]==8) || (($key[0] eq "") && (!$key[1]))) && do {	# DownArrow
		    $self->linemove (1,1);
		};
		(($key[1]==9) || (($key[0] eq "") && (!$key[1]))) && do {	# RightArrow
		    unless ($$self[7]==length($$self[6])-1) {
			$$self[7]++;
		    }
		};
		(($key[1]==10) || (($key[0] eq "") && (!$key[1]))) && do {	# LeftArrow
		    if ($$self[7]) {
			$$self[7]--;
		    }
		};
		$self->cursor;
		$self->statusbar;
		($col, $line, $len) = $self->cursor;
		refresh ($$self[0]);
	    }
	}
    }
}

package PV::Dialog;
use Curses;

sub new {			# The dialog box object
    my $type=shift;		# PV::Dialog ("Label",x1,y1,x2,y2,style,color,
    my @params=(0,@_);		#            Control1,1,2,3,4,5,6,7,8,
    my $self=\@params;		#            Control2,1,2,3,4,5,6,7,8,...)
    $$self[0] = newwin($$self[5]-$$self[3]+1,$$self[4]-$$self[2]+1,$$self[3]-1,$$self[2]-1);
    bless $self;      
}

sub display {
    my $self=shift;
    PV::mybox (0,0,$$self[4]-$$self[2],$$self[5]-$$self[3],1,1,$$self[0]);
    my $i=8;
    while ($i+7 < $#$self) {
	$$self[$i][0]=$$self[0];
	($$self[$i])->place;
	$i+=9;
    }
    refresh($$self[0]);
}

sub activate {
    my $self=shift;
    $self->display;
    my $i=1; my @last=();
    while ($i) {
	@last=($i,($$self[8+(($i-1)*9)]->activate));
	$i=$$self[8+(($i-1)*9)+$last[1]];
    }
    $self->hide;
    refresh($$self[0]);
    return (@last);
}

sub hide {
    my $self=shift;
    touchwin(stdscr);
    refresh(stdscr);
}

package PV::PVD;		# Two commonly needed dialog box types

sub message {
    my ($message,$width,$depth)=@_;
    ($width<11) && ($width=11);
    $depth+=4;
    my $x1=int ((80-$width)/2);
    my $y1=4 + int ((19-$depth)/2);
    my $x2=$x1+$width;
    my $y2=$y1+$depth;
    my $static=new PV::Static($message,2,1,$x2-$x1,$y2-$y1-4);
    my $ok = new PV::Cutebutton(" OK ",int($width/2)-3,$y2-$y1-2);
    my $dialog = new PV::Dialog ("",$x1,$y1,$x2,$y2,1,1,
				$ok,1,1,1,1,1,1,1,0,
				$static,0,0,0,0,0,0,0,0);
    $dialog->activate;
}

sub yesno {
    my ($message,$width,$depth)=@_;
    my @message=split("\n",$message);
    ($width<21) && ($width=21);
    $depth+=4;
    my $x1=int ((80-$width)/2);
    my $y1=4 + int ((19-$depth)/2);
    my $x2=$x1+$width;
    my $y2=$y1+$depth;
    my $static=new PV::Static($message,2,1,$x2-$x1,$y2-$y1-4);
    my $yes = new PV::Cutebutton (" YES ",int($width/2)-9,$y2-$y1-2);
    my $no = new PV::Cutebutton (" NO ",int($width/2)+2,$y2-$y1-2);
    my $dialog = new PV::Dialog ("",$x1,$y1,$x2,$y2,1,1,
				$yes,1,1,2,1,1,1,2,0,
				$no,2,3,2,1,2,2,1,0,
				$static,0,0,0,0,0,0,0,0);
    my $stat=($dialog->activate)[0];
    ($stat==2) && ($stat=0);
    return $stat;
}

"PerlVision. (C) Ashish Gulhati, 1995";
