var board = [];
var columns;
var rows;
var mineslocation = [];
var mineCount;
var origminecount
var flagenabled = false;
var tilesclicked = 0;
var gameover = false;

function check(){ /* pārbauda vai dati ir reālā daudzumā */
    columns = document.getElementById("columns").value;
    rows = document.getElementById("rows").value; 
    mineCount = document.getElementById("bombs").value;
    origminecount = document.getElementById("bombs").value;
    if(rows * columns >= mineCount){
        gamestart()
    }
    else {
        alert("pārāk daudz bumbas");
    }
}

function placemines(){
    let minesleft = mineCount;
    while(minesleft > 0){
        let r = Math.floor(Math.random() * rows);
        let c = Math.floor(Math.random() * columns);
        let id = r.toString() + "-" + c.toString();
        console.log(id);

    if(!mineslocation.includes(id)){
        mineslocation.push(id);
        minesleft -= 1;

    }

    }

}

function gamestart(){

    document.getElementById("board").style.width = ((rows * 28) + "px");
    document.getElementById("board").style.height = ((columns * 28) + "px");

    document.getElementById("minecount").innerText = mineCount;
    placemines();
    for(var r = 0;r < rows; r++){
        let row=[];
        for(var c = 0; c < columns; c++){
            let tile = document.createElement("div"); /* izveido <div> izmantojot 2d masivu*/
            tile.id = r.toString() + "-" + c.toString();
            tile.addEventListener("click", clicktile); /* izpilda funkciju clicktile kad uzspiež uz mazās ailes */
            tile.addEventListener("contextmenu", placeflag); /* izpilda funkciju placeflag kad uzspiež ar labo pogu */
            document.getElementById("board").append(tile); /* ievito <div> 2d masivu iekšā "board" */
            row.push(tile); /* saliek 2d masiva rindas row masivā */
        }
        board.push(row); /* saliek row masiva rindas board masīvā */
    }
    console.log(board)
}
/* uzliek un noņem karogu */

function placeflag(a){ 
a.preventDefault();  
let tile = this;
if(gameover == false){
    if(tile.innerText == ""){
        tile.innerText = "🏁";
        mineCount -= 1;
    }                                   
    else if(tile.innerText == "🏁"){
        tile.innerText = "";
        mineCount += 1;
    }
    document.getElementById("minecount").innerText = mineCount;
    return;
}
}

/* uzliek un noņem karogu no ailes */
function clicktile() { 
    if(gameover){
        return;
    }

    let tile = this;
    if(tile.innerText == ""){
        if(mineslocation.includes(tile.id)){ /* zaudē spēli ja uzspiež uz bumbas */
            gameover=true;
            revealmines();
        return;
        }
    

    let coords = tile.id.split("-");
    let r = parseInt(coords[0]);
    let c = parseInt(coords[1]);
    checkmine(r, c);
    }
}

function revealmines(){             /* atklāj visas bumbas kad zaudē */
    for(var r = 0;r < rows; r++){
        for(var c = 0; c < columns; c++){
            let tile = board[r][c];
            if (mineslocation.includes(tile.id)){
                tile.innerText = "💣";
                tile.style.backgroundColor = "red";
            }
        }
    }
}

function checkmine(r, c){ /* izsauc funkciju checktile uz katras ailes apkārt uzspiestajai ailei */
    if (r<0 || r>=rows || c<0 || c>=columns){
        return 0;
    }
    if(board[r][c].classList.contains("clicked-tile")){
        return;
    }
    board[r][c].classList.add("clicked-tile");
    tilesclicked += 1;
    let minesfound = 0;

    minesfound += checktile(r-1, c-1); /* aukšējās 3 ailes */
    minesfound += checktile(r-1, c);
    minesfound += checktile(r-1, c+1);

    minesfound += checktile(r, c+1); /* sāna ailes */
    minesfound += checktile(r, c-1);

    minesfound += checktile(r+1, c-1); /* apakšējās 3 ailes */
    minesfound += checktile(r+1, c);
    minesfound += checktile(r+1, c+1);

    if(minesfound > 0){
        board[r][c].innerText = minesfound;
        board[r][c].classList.add("num" + minesfound.toString());
    }
    else { /* atkārtoti izmanto funkciju checkmine apkārt uzspiestai ailei lai atklāt blakus ailes */

        checkmine(r-1, c-1); /* aukšējās 3 ailes */ 
        checkmine(r-1, c);
        checkmine(r-1, c+1);

        checkmine(r, c+1); /* sāna ailes */
        checkmine(r, c-1);

        checkmine(r+1, c-1); /* apakšējās 3 ailes */
        checkmine(r+1, c); 
        checkmine(r+1, c+1);
    }
    console.log(tilesclicked);
    console.log(origminecount);

    if(tilesclicked == rows * columns - origminecount){
        gameover = true;
        alert("you won");
    }
}

function checktile(r, c){
    if (r<0 || r>=rows || c<0 || c>=columns){
        return 0;
    }
    if(mineslocation.includes(r.toString() + "-" + c.toString())){ /* return 1 vai 0 atkarīgi no tā, vai šajā ailē ir bumba */
        return 1;
    }
    return 0;
}