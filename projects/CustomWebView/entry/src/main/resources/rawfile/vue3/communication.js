function startDraw() {
  if (isClick) {
    count = 0;
    index = Math.floor(Math.random() * prizesArr.length + 1);
    roll();
    isClick = false;
  }
}
function openDialog() {
  linkObj.messageFromHtml(prizesArr[prizesPosition]);
}
document._initMsg = 'hello vue'
function outWeb(){
  document._changeMsg('I am Web')
}
document._sendMsgToWeb = (val) =>{
  linkObj.messageFromHtml(val);
}