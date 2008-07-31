<?php

// Cookie-based authentication logic

class User {
  var $db = null;
  var $id = 0; // the current user's id
  var $username = null;
  var $cookieName = "DollarLogin";
  function User(&$db) {
    $this->db = $db;
    if ( isset($_COOKIE[$this->cookieName]) ) {
      $this->_checkRemembered($_COOKIE[$this->cookieName]);
    }
  } 

  function _checkLogin($username, $password) {
    $sql = "SELECT Salt FROM Person WHERE Username = '$username'";
    $rs = $this->db->executeQuery($sql);
    $salt = $rs->getValueByNr(0,0);
    $hashedpassword = md5($password.$salt);
    $sql = "SELECT * FROM Person WHERE " .
           "Username = '$username' AND " .
           "Password = '$hashedpassword'";
    $result = $this->db->executeQuery($sql);
    if ( $result->next() ) {
      $this->_setCookie($result, true);
      return true;
    } else {
      return false;
    }
  } 
	
  function _addRegistration($username, $password) {
    $sql = "SELECT PersonID FROM Person WHERE Username='$username'";
    $rs = $this->db->executeQuery($sql);
    if( $rs->next() ) return false;  // User already exists
    $salt = substr(md5(rand()), 0, 4);
    $hashedpassword = md5($password.$salt);
    $sql = "INSERT INTO Person (Username, Password, Salt) " .
           "VALUES ('$username', '$hashedpassword', '$salt')";
    $this->db->executeQuery($sql);
    return $this->_checkLogin($username, $password);
  }
	
  function _logout() {
    if(isset($_COOKIE[$this->cookieName])) setcookie($this->cookieName);
    $this->id = 0;
    $this->username = null;
  }

  function _setCookie(&$values, $init) {
    $this->id = $values->getCurrentValueByName("PersonID");
    $this->username = $values->getCurrentValueByName("Username");
    $token = md5($values->getCurrentValueByName("Password").mt_rand());
    $this->_updateToken($token);
    $session = session_id();
    $sql = "UPDATE Person SET Token = '$token' " .
           "WHERE PersonID = $this->id";
    $this->db->executeQuery($sql);
  } 

  function _updateToken($token) {
    $arr = array($this->username, $token);
    $cookieData = base64_encode(serialize($arr));
    setcookie($this->cookieName, $cookieData, time() + 31104000);
  }
	
  function _checkRemembered($cookie) {
    $arr = unserialize(base64_decode($cookie));
    list($username, $token) = $arr;
    if (!$username or !$token) {
      return;
    }
    $sql = "SELECT * FROM Person WHERE " .
           "(Username = '$username') AND (Token = '$token')";
    $rs = $this->db->executeQuery($sql);
    if ( $rs->next() ) {
      $this->id = $rs->getCurrentValueByName("PersonID");
      $this->username = $rs->getCurrentValueByName("Username");
    }
  } 
}
?>
