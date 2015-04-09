#!/usr/bin/perl

#root directory is recognized as the directory this file is placed in. 

use CGI;

BEGIN
{
    $q = new CGI;

    $u_c = $q->param("u_c");
    $p_c = $q->param("p_c");
    $r_a_c = $q->param("r_a_c");

    $action = $q->param("action");
    $raw = $q->param("raw");
    $code = $q->param("code");

    #name of file/directory/path to open
    $name = $q->param("name");

    print $q->header(-type=>'text/html', -charset => 'UTF-8');
    open(STDERR, ">&STDOUT");
}

$req_div = qq{
    <form action='' method='GET'>
        u:<input type='text'/ name='u_c' value='$u_c'>    </br>
        p:<input type='text'/ name='p_c' value='$p_c'>    </br>
        rac:<input type='text'/ name='r_a_c' value='$r_a_c'>    </br>
        action:<input type='text'/ name='action'>    </br>
        raw:<input type='text'/ name='raw'>    </br>
        code:<input type='text'/ name='code'>    </br>
        name:<input type='text'/ name='name'>    </br>
        <input type='submit' value='POST PARAM'>
    </form>
};

if(!defined $u_c)
{
    print $req_div;
}
else
{
    #remove in public
    print $req_div;

    $response = try_login($u_c, $p_c, $r_a_c);
    if($response =~ /^(failed)$/)
    {
        $key = "false";
        die "Authentication Failed\n";
    }
    if($response =~ /^(success)$/)
    {
        $key = "valid";
        print "Authentication Success\n";
        if(!defined $action)
        {
            list_directory('root_x9');
        }
        else
        {
            action_dir($action);
        }
    }
}

sub list_directory
{
    my ($name) = @_;

    if($name =~ /^(root_x9)$/)
    {
        $directory = ".";
    }
    else
    {
        $directory = $name;
    }

    opendir (DIR, $directory) or action_open($directory);
    my @file_list = readdir(DIR);
    closedir(DIR);

    foreach (@file_list)
    {
        if((-d $_)) 
        {
            if($_ =~ /^(.|..)$/){}else{push(@folders, $_);}
        }
        if((-f $_))
        {
            push(@files, $_);
        }
    }
    my @sorted_folders = sort{lc($a) cmp lc($b)}@folders;
    foreach (@sorted_folders)
    {
        print "<p style='color:red'>" . $_ . "</p>";
    }
    my @sorted_files = sort{lc($a) cmp lc($b)}@files;
    foreach (@sorted_files)
    {
        print "<p style='color:green'>" . $_ . "</p>";
    }
    
}

sub try_login
{
    my ($u_cg, $p_cg, $r_a_cg) = @_;

    if($u_cg !~ /^(enc_username)$/)
    {
        return "failed";
        exit;
    }
    if($p_cg !~ /^(enc_password)$/)
    {
        return "failed";
        exit;
    }
    if($r_a_cg !~ /^(random_device_idn)$/)
    {
        return "failed";
        exit;
    }
    return "success";
    exit;
}