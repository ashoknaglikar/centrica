


body{margin:0; padding:0}
        .page{font-family: 'SansSerif'; font-size: 85%; background:white; margin-left: auto;margin-right: auto;}
        .content{width:86%; margin-left: auto; margin-right: auto;}
        .clearfix:after {content: " ";visibility: hidden;display: block;height: 0;clear: both;}
        
        /*--Tags and classes using bold font--*/
        h1,h2,h3{font-family: 'SansSerif';}
        .bold{font-family: 'SansSerif'; font-weight:bold;}
        
        h1{color: #00B2DA;font-weight:lighter;}
        h2{color: #00FFFF;}
        h3{color: #00FFFF;}
        .body   {margin-top: 2em}
        
        .smaller{font-size: smaller;}
        .asbestosIdentified {color:red; font-weight:bold; margin-bottom:0.5em}
        .warning{border:solid 1px red;padding:0.5em; border-radius:8px; color:red; display:inline-block}
        .warning p {margin: 0.2em;}
        
        .noAsbestos{color:green}

        .whiteBackground{background-color:white;}
        .boldFont{font-weight:bold;}
        
        .table  { display: table; width: 100%; }
        .row    { display: table-row; height: 70px; width:100%; }
        .cell   { display: table-cell; border: 1px solid #FFFFFF; padding: 10px; }
        
        .cell-dark  {background-color: #B0E2EC;}
        .cell-light {background-color: #D6F1F5;}
        .cell-left  {width: 30%; display: inline-block;}
        .cell-right {width: 69%; display: inline-block;}
        
        input[type=text], textarea {-webkit-appearance: none; -webkit-border-radius:0; font-family: 'SansSerif'; font-size: 15px; padding: 3px; border-radius:0; border-style: none;}
        input[type=text] { height: 25px; box-sizing: border-box; width: 100%;}
        textarea {width: 100%;}
    
        .footer {bottom: 0px; font-size: smaller; margin-top: 10px}
        .version{ -webkit-transform: rotate(270deg);}
        
        .inlineDivs{
           width: 30%;
        }

        .moreSpace{
            margin-top: 10px;
            margin-bottom: 5px;
        }
        .mediumDiv{
            margin-top: 5px;
            margin-bottom: 5px;
        }

        .bigDiv{
            font-family: 'BGFlame';
            font-size: 14px;
            margin-top: 10px;
            margin-bottom: 10px;
        }

        .bgLogo{float:right;}

        .smallWidth{width: 30%;}

        .mediumWidth{
            width: 50%;
        }

        .simpleTable{
            font-size: 13px;
            background-color: #D6F1F5;
            border-collapse: collapse;
            margin-top:2px;
            margin-bottom:2px;
            padding:2px;
            border:2px solid #ffffff;
            text-align: left;
        }


        .radiatorTable {
            border-collapse: collapse;
            width: 100%;
            background-color: #D6F1F5;
           text-align: left
        }

       .radiatorTable tr:nth-child(even){background-color: white;}
       .radiatorTable th{font-weight:bold}
        
        .newPage{margin-top:2em}
        @page{
            margin-bottom:30mm;
            margin-top:25mm;
        }

        @font-face {
            font-family: "BGFlame";
            src: url('{!URLFOR($Resource.BGFlame)}');
        }

            



