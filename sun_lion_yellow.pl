#!/usr/bin/env perl

use strict;
use warnings;

use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;
use DBI;

my $dsn  = "dbi:mysql:dbname=dbname;host=localhost;port=3306";
my $user = "username";
my $pass = "password";

my $dbh = DBI->connect($dsn, $user, $pass);

# print the page header
print header;

# create the form
print start_form(-name=>'MainForm', -method=>'POST', -action=>'/workspace.pl');

# create the form labels
print "Enter Your Artist's Name: ", textfield(-name=>'name');
print br;

# create the submit button
print submit(-name=>'submit', -value=>'Submit');
print end_form;

# process the form input
if (param('submit')) {
	
	# retrieve the input
	my $name = param('name');
	
	# check if the artist exists already
	my $sth = $dbh->prepare('SELECT * FROM artists WHERE name = ?');
	$sth->execute($name);
	if ($sth->rows > 0) {
		print "<p>Welcome back $name!</p>";
	} else {
		# artist is not in the database, so add them
		my $ins_sth = $dbh->prepare('INSERT INTO artists (name) VALUES (?)');
		$ins_sth->execute($name);
		print "<p>Thank you for joining $name!</p>";
	}
	
	# retrieve all of the projects
	my $projects_sth = $dbh->prepare('SELECT * FROM projects');
	$projects_sth->execute();
	
	# print out the project selection dropdown
	print '<p>Select a project to join: ', 
		popup_menu(-name=>'projects', -values=>['Choose a Project', $projects_sth->fetchall_arrayref()]);
	print br, submit(-name=>'submit_project', -value=>'Submit'), '</p>';
	
	# process the form input
	if (param('submit_project')) {
		
		# retrieve the selected project
		my $project = param('projects');
		
		# check if the artist is already part of the project
		my $check_sth = $dbh->prepare('SELECT * FROM project_members WHERE project_name = ? AND artist_name = ?');
		$check_sth->execute($project, $name);
		if ($check_sth->rows > 0) {
			print "<p>You are already part of the $project project!</p>";
		} else {
			# artist is not part of the project, so add them
			my $ins_sth = $dbh->prepare('INSERT INTO project_members (project_name, artist_name) VALUES (?, ?)');
			$ins_sth->execute($project, $name);
			print "<p>Welcome to the $project project, $name!</p>";
		}
	}
}

# print the page footer
print end_html;