<?php 
  function nav_start_outer($page_title = null) { 
?><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3. org/TR/html4/loose.dtd">
<HTML>
<HEAD>
<link rel="stylesheet" type="text/css" href="includes/layout.css" />
<TITLE><?php echo "$page_title - " ?>Mutual Bank
</TITLE>
</HEAD>
<?php
  $pageName = ucfirst(basename($_SERVER['SCRIPT_NAME'], ".php"));
	global $user;
	if($user->id) 
	{
  echo "<h1><a href='index.php'>Mutual Bank -- $pageName Page</a></h1>";
	}
	else
	{
  echo "<h1><a href='index.php'>Mutual Bank -- Login Page</a></h1>";
	}

} function nav_start_inner() { ?>

<div id="navbar">

<ul><?php
// Output a pipe-delimited list of available pages
global $user;
if($user->id) 
{
$pages = array( "Home" => "index.php", 
                "Users" => "users.php", 
		"Buy Stock" => "stock.php",
		"Send Money" => "transfer.php",
		"New Feature" => "customizer.php" );
foreach($pages as $name => $page) {
  $script = $_SERVER['SCRIPT_NAME'];
  if(strpos($script, $page, strlen($script) - strlen($page)) === false) {
    echo "<li><a href=$page>$name</a></li>";
  } else {
    echo "<li><b>$name</b></li>";
  }
  echo "<hr>";
}
}
?></ul>
<div id="header">
<div>UC Berkeley CS 101</div>
<div><a href="?action=logout"><?php 
  global $user;
  if($user->id) 
    echo "Log out " . htmlspecialchars($user->username); 
  else
	  echo "<a href='index.php'>Login</a>";
?></a></div>
</div>
</div>
<div id="main" class="centerpiece">
<table>
<tr><td class=main>

<?php } function nav_end_inner() { ?>

</td></tr>
</table>
</div>

<?php } function nav_end_outer() { ?>

</BODY>
</HTML>

<?php } ?>
