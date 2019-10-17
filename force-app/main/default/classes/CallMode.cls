/*
This class stores the code for various inbound calls
*/
public class CallMode 
{
    public Integer CUSTOMERCALLNEWCUST     { set; get{ return 1;} }
    public Integer CUSTOMERCALLEXISTCUST   { set; get{ return 2;}}
    public Integer ENGINEERCALLNEWCUST     { set; get{ return 3;}}
    public Integer ENGINEERCALLEXISTCUST   { set; get{ return 4;}}
    public Integer EMPLOYEECALLNEWCUST     { set; get{ return 5;}}
    public Integer EMPLOYEECALLEXISTCUST   { set; get{ return 6;}}
    public Integer HSACALL                 { set; get{ return 7;}}
    public Integer WASTECALL               { set; get{ return 8;}}
}