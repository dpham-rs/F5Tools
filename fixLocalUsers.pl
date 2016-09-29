#!/usr/bin/perl

my %global;

if ($ARGV[0] ne "debug") { $global{'debug'} = 0; }
if ($ARGV[0] eq "debug") { $global{'debug'} = 1; }


$usersFile = "/config/bigip_sys.conf";
my $version = getVersion(); 

my %userList; my %_userList;
if ($version =~ /^10\./) { $localUsersFile = "/config/bigip_sys.conf"; }
if ($version =~ /^10\.0/) { $localUsersFile = "/config/bigip.conf"; }
if ($version =~ /^9\./) { $localUsersFile = "/config/bigip_sys.conf"; }
if ($version =~ /^11\./) { $localUsersFile = "/config/bigip_user.conf"; }
if ($version =~ /^12\./) { $localUsersFile = "/config/bigip_user.conf"; }

getLocalUserList($localUsersFile, \%userList, $version);
checkAuthFile("/config/bigip/auth/localusers", \%_userList);
auditUsers(\%userList, \%_userList, "/config/bigip/auth/localusers");
exit;
#------------------------------------------------------------------------------
sub auditUsers
{  
   my ($h1, $h2, $f) = @_;
   foreach $user (keys %{$h1})
   {
      if ( ! $$h2{$user} )
      {
         logger("User [$user] is not defined in localusers file");
         push(@changes, $user);
      }
   }
   
   if (scalar(@changes) > 0)
   {
      open (F, ">>$f") or die "cannot open $f in append mode";
      foreach (@changes)
      {
         logger("Adding $_ to the localusers file");
         print F "$_\n";
      }
      close F;
   }
   else
   {
      logger("All " . scalar(keys %{$h1}) . " users are already defined in the localusers file");
   }
   return;
}
#------------------------------------------------------------------------------
sub checkAuthFile
{
   my ($f, $_localUsers) = @_;
   logger("Checking $f for the defined local users");
   open (F, "$f") or die "cannot open file $f to read";
   while (<F>)
   {
      chomp;
      next if (/^\#/);
      next if length($_) == 0;
      #print "LocalUser in file >$_<\n";
      $$_localUsers{$_} = 1;
   }
   return;
}
#------------------------------------------------------------------------------
sub getLocalUserList
{
   my ($f, $localUsers, $f5Version) = @_;
   open (F, "$f") or die "cannot open file $f to read";
   while (<F>)
   {
      chomp;
      if ($f5Version =~ /^9\./ || $f5Version =~ /^10\./)
      {
         if (/^user/ && /\{$/)
         {
            #print $_, "\n";
            ($j, $userName, $j2) = split(/\s+/);
            #print "LocalUser = $userName\n";
            $$localUsers{$userName} = 1;
         }
      }
      if ($f5Version =~ /^11\./ || $f5Version =~ /^12\./ )
      {
         if (/^auth user/ && /\{$/)
         {
            #print $_, "\n";
            my @j = split(/\s+/);
            #print "LocalUser = $userName\n";
            $$localUsers{$j[2]} = 1;
         }
      }
      
   }
   close F;
   return;
}
#------------------------------------------------------------------------------
sub getVersion
{
  # open /etc/issue and parse the version
  logger("Determining device version");
  open (F, "/etc/issue");
  while (<F>)
   {
      chomp;
      if (/^BIG-IP/)
      {
         my @v = split(/\s+/); 
         #print join("|" , @v) . "\n";
         $f5Version = $v[1] . "." . $v[3];
         $baseVer = $v[1];
         $minorVer = $v[3];
      }
   }
   close F;
   logger("Device Version is $f5Version");
   return $f5Version;
}
#------------------------------------------------------------------------------
sub logger
{
   my ($str) = @_;
   if ($global{'debug'} ==1)
   {
      print "DEBUG::$str\n";
   }
   return;
}
#------------------------------------------------------------------------------

