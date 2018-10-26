use strict;
use warnings;

use Tk;
use Tk::DialogBox;

my $x = 9;
my $y = 9;
my $n = 9;
my $f = 0;

my @colour = ('black', 'green', 'blue', 'red', 'red', 'red', 'red', 'red', 'black');
my @numbers = (9, 11, 15);
my @numbers1 = (9, 11, 15,21,33);

my $cellH = 1; 
my $cellW = 2; 

my $flagChar = "\x{2691}"; # 'F'
my $mineChar = "\x{2600}"; # '*'
my $boomChar = "\x{2620}"; # 'X'
my $noneChar = " ";        # ' '

my %widgets; 
my %values; 

my %uncovered = ();
my %flagged = ();

my $mw = MainWindow->new;
$mw->title("Minesweeper-PERL");
$mw->configure(-background => 'yellow');
$mw->resizable(100,100);

$mw->protocol('WM_DELETE_WINDOW', sub {
                my $answer = $mw->messageBox(-title => 'Do you want to exit?',
                                             -message=>'press no to cancel',
                                             -type => 'yesno', -icon => 'info', -default => 'Yes');

                if($answer eq 'Yes') {
                  $mw->destroy;
                  exit 0;
                }
              });

InitGame();

MainLoop;


sub InitGame {
  $mw->withdraw;
  Configure();
  InitField();
  InitUI();
  $mw->deiconify;
}

sub Configure {
  
  my $it = AllPairs([0..$x-1], [0..$y-1]);
  while(my ($i, $j) = $it->()) {
    $widgets{$i}{$j}->destroy() if(exists $widgets{$i}{$j} && defined $widgets{$i}{$j});
  }

  
  my $sizeBox = $mw->DialogBox(-title => "Field size?", -buttons => [map {$_.'x'.$_} @numbers]);
  $sizeBox->transient(undef);
  my $response = '';
  while(!defined($response = $sizeBox->Show(-popover => $mw))) { }
  ($x, $y) = ($response =~ /(\d+)x(\d+)/);

  for my $i (0..$x-1) { $mw->gridColumnconfigure($i, -pad => 2); }
  for my $i (0..$y-1) { $mw->gridRowconfigure($i, -pad => 2); }

  
  my $mineBox = $mw->DialogBox(-title => "How many mines?", -buttons => [map { $_ } @numbers1]);
  $mineBox->transient(undef);
  while(!defined($n = $mineBox->Show(-popover => $mw))) { }
}

sub InitField {
  
  my $it = AllPairs([0..$x-1], [0..$y-1]);
  while(my ($i, $j) = $it->()) {
    $values{$i}{$j} = 0;
  }

  
  srand(time());
  for (1..$n) {
    MORE_SIR:
      my $i = int(rand($x));
      my $j = int(rand($y));
      if($values{$i}{$j} != 0) { goto MORE_SIR; } 
      else { $values{$i}{$j} = -1; }
  }

 
  my $all = AllPairs([0..$x-1], [0..$y-1]);
  while(my ($i, $j) = $all->()) {
    
    if($values{$i}{$j} == -1) {
      my $neighbor = Neighbors($i,$j);
      while(my ($s, $t) = $neighbor->()) {
        $values{$s}{$t} += 1 if($values{$s}{$t} != -1);
      }
    }
  }
}

sub InitUI {
  %uncovered = ();
  %flagged = ();

  my $f = 0; 

  
  my $it = AllPairs([0..$x-1], [0..$y-1]);
  while(my ($i, $j) = $it->()) {
    $widgets{$i}{$j} = $mw->Button(-text => $noneChar,
                                   -command => [\&Check, $i, $j],
                                   -height => $cellH, -width => $cellW, -borderwidth => 1,
                                   -font => [-size => 10, -weight => 'bold', -family => 'courier']
                                  )->grid(-column => $i, -row => $j);

    $widgets{$i}{$j}->bind("<Button-3>", [\&FlagOrUnflag, $i, $j]);
  }
}

sub CheckForVictory {
  if($f > $n) {
    $mw->messageBox(-title => 'Too many flags...',
                    -message => 'There are a bit too many flags... remove some',
                    -type => 'ok', -icon => 'warning', -default => 'ok');

    return;
  }

  my $all = AllPairs([0..$x-1], [0..$y-1]);
  my $cnt = 0;
  while(my ($i, $j) = $all->()) {
    $cnt++ if($values{$i}{$j} == -1 && exists $flagged{$i}{$j});
  }

  if($cnt == $n) {
    my $all = AllPairs([0..$x-1], [0..$y-1]);
    while(my ($i, $j) = $all->()) {
      if($values{$i}{$j} == -1) {
        UncoverTile($i, $j, $mineChar);
      }
    }

    my $answer =$mw->messageBox(-title => 'Victory!',
                                -message => "Against all odds, you won!\nPlay again?",
                                -type => 'yesno', -icon => 'info', -default => 'yes');
    if ($answer eq 'Yes') {
      InitGame();
    }
    else {
      $mw->destroy;
      exit 0;
    }
  }
}

sub FlagOrUnflag {
  my ($b, $i, $j) = @_;


  if(!exists $flagged{$i}{$j}) {
    $b->configure(-text => $flagChar);
    $flagged{$i}{$j} = 1;
    $f++;
  }
 
  else {
    $b->configure(-text => $noneChar);
    delete $flagged{$i}{$j};
    $f--;
  }

  CheckForVictory();
}

sub AllPairs {
  my ($A, $B) = @_;
  my @values = ();
  for my $i (@$A) {
    for my $j (@$B) {
      push @values, $i;
      push @values, $j;
    }
  }

  
  my $i_ = 0;
  my $j_ = 1;
  return sub { return unless($i_ < @values);
               my $x_ = $values[$i_]; $i_ += 2;
               my $y_ = $values[$j_]; $j_ += 2;
               return ($x_, $y_);
             }
}




sub UncoverTile {
  my ($i, $j, $s) = @_;

  
  return if(exists $flagged{$i}{$j});

  
  my $value = $values{$i}{$j};
  $s = (($value==0)?$noneChar:$value) if(!defined $s);

  
  $widgets{$i}{$j}->destroy();

  $widgets{$i}{$j} = $mw->Label(-text => $s,
                                -bg => 'white', -fg => $colour[$value],
                                -height => $cellH, -width => $cellW, -borderwidth => 3,
                                -font => [-size => 10, -weight => 'bold', -family => 'courier']
                               )->grid(-column => $i, -row => $j);

  $uncovered{$i}{$j} = 1; 
}


sub Percolate {
  my ($i, $j) = @_;

  my @stack = ();
  push @stack, [$i, $j];

  while(@stack > 0) {
    my ($a, $b) = @{pop @stack};

    
    if(!exists $uncovered{$a}{$b}) {
      my $value = $values{$a}{$b};

      UncoverTile($a,$b);

      
      if($value == 0) {
        my $neighbor = Neighbors($a,$b);
        while(my ($s, $t) = $neighbor->()) {
          push @stack, [$s, $t];
        }
      }
    }
  }
}
#code to see neighbors of selected tile and also function for uncover all mines when game gets over 

sub Neighbors {
  my ($i,$j) = @_;
  my @neighbors = ();

  
  my $offsets = AllPairs([-1..1],[-1..1]);
  while(my ($s, $t) = $offsets->()) {
    
    if(($s != 0 || $t != 0) &&
       ($i+$s >= 0) && ($i+$s < $x) &&
       ($j+$t >= 0) && ($j+$t < $y) ) {
      push @neighbors, $i+$s;
      push @neighbors, $j+$t;
    }
  }

  my $i_ = 0;
  my $j_ = 1;
  sub { return unless($i_ < @neighbors);
        my $x_ = $neighbors[$i_]; $i_ += 2;
        my $y_ = $neighbors[$j_]; $j_ += 2;
        return ($x_, $y_);
  }
}

sub UncoverAllMines {
  my $all = AllPairs([0..$x-1], [0..$y-1]);
  while(my ($i, $j) = $all->()) {
    if($values{$i}{$j} == -1) {
      UncoverTile($i, $j, $mineChar);
    }
  }
}

sub Check {
  my ($i, $j) = @_;

  my $value = $values{$i}{$j};

  
  if($value == -1) {
    UncoverAllMines();              
    UncoverTile($i, $j, $boomChar); 

    my $answer = $mw->messageBox(-title => 'BOOOOOOOOOOM!',
                                 -message => "A nuclear blast whiped you from the face of earth...\nPlay again?",
                                 -type => 'yesno', -icon => 'error', -default => 'yes');
    if ($answer eq 'Yes') {
      InitGame();
    }
    else {
      exit;
    }
  }
  
  elsif($value > 0) {
    UncoverTile($i,$j);
  }
  
  else {
    Percolate($i,$j);
  }
}

