# AuthLogSQLUSEREXISTS.pm
#
# Specific class for logging authentication to SQL but only when the user is known
# This is to avoid possible SQL issues when there are DOS attacks for example
# This is a copy of AuthLogSQL with minor modification
#
# Specific use case:
#   AuthLogSQL can be used for updating a user's last login or failed login attempts in DB
#   But unknown users will also be logged with the standard AuthLogSQL module and this 
#   means unnecessary DB requests because there is nothing to update
# 
# Updated: Maarten Wallraf <maarten@2nms.com>
#
# Author: contributed by Dave Lloyd <david@freemm.org>
# $Id: AuthLogSQL.pm,v 1.16 2008/04/13 00:03:45 mikem Exp $

package Radius::AuthLogSQLUSEREXISTS;
@ISA = qw(Radius::AuthLogGeneric Radius::SqlDb);
use Radius::AuthLogGeneric;
use Radius::SqlDb;
use strict;

%Radius::AuthLogSQLUSEREXISTS::ConfigKeywords =
 ('Table'        =>
  ['string', 'This optional parameter specifies the name of the SQL table where the logging messages are to be inserted. Defaults to RADAUTHLOG.', 1],

  'SuccessQuery' =>
  ['string', 'This optional parameter specifies the SQL query that will be used to log authentication successes if LogSuccess is enabled (LogSuccess is not enabled by default). There is no default. If SuccessQuery is not defined (which is the default), no logging of authentication successes will occur. In the query, special formatting characters are permitted, %0 is replaced with the message severity level. %1 is replaced with the quoted reason message (which is usually empty for successes). %2 is replaced with the SQL quoted User-Name. %3 is replaced with the SQL quoted decoded plaintext password (if any). %4 is replaced with the SQL quoted original user name from the incoming request (before any RewriteUsername rules were applied)', 1],

  'FailureQuery' =>
  ['string', 'This optional parameter specifies the SQL query that will be used to log authentication failures if LogFailure is enabled (LogFailure is enabled by default). There is no default. If FailureQuery is not defined (which is the default), no logging of authentication failures will occur. In the query, special formatting characters are permitted, %0 is replaced with the message severity level. %1 is replaced with the quoted reason message. %2 is replaced with the SQL quoted User-Name. %3 is replaced with the SQL quoted decoded plaintext password (if any). %4 is replaced with the SQL quoted original user name from the incoming request (before any RewriteUsername rules were applied)', 1],

  );

# RCS version number of this module
$Radius::AuthLogSQLUSEREXISTS::VERSION = '$Revision: 1.16 $';

#####################################################################
sub activate
{
    my ($self) = @_;

    $self->Radius::AuthLogGeneric::activate;
    $self->Radius::SqlDb::activate;
}

#####################################################################
# Do per-instance default initialization
# This is called by Configurable during Configurable::new before
# the config file is parsed. Its a good place initialize instance
# variables
# that might get overridden when the config file is parsed.
# Do per-instance default initialization. This is called after
# construction is complete
sub initialize
{
    my ($self) = @_;

    $self->Radius::AuthLogGeneric::initialize;
    $self->Radius::SqlDb::initialize;
    $self->{Table} = 'RADAUTHLOG';
}

#####################################################################
# Log a message
sub authlog
{
    my ($self, $s, $reason, $p) = @_;

    if (defined($self->{SuccessQuery})
	&& $self->{LogSuccess}
	&& $s == $main::ACCEPT)
    {
	return unless $self->reconnect();
	$self->do(&Radius::Util::format_special
		  ($self->{SuccessQuery}, $p, $self,
		   $s,
		   $self->quote($reason),
		   $self->quote($p->getUserName()),
		   $self->quote($p->decodedPassword()),
		   $self->quote($p->{OriginalUserName}),
		   ));

    }
    elsif (defined($self->{FailureQuery})
	   && $self->{LogFailure}
	   && $s == $main::REJECT)
    {

        if ($reason == $self->quote("No such user")) {
            my $usr = $p->getUserName();
            &main::log($main::LOG_DEBUG, "Skip SQL logging - $reason: $usr");
            return;
        }

	return unless $self->reconnect();
	$self->do(&Radius::Util::format_special
		  ($self->{FailureQuery}, $p, $self,
		   $s,
		   $self->quote($reason),
		   $self->quote($p->getUserName()),
		   $self->quote($p->decodedPassword()),
		   $self->quote($p->{OriginalUserName}),
		   ));
    }
}

1;

