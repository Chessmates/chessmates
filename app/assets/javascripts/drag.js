$(function() {

  $(".draggable").draggable({
    containment: '.chessboard',
    cursor: 'move',
    revert: function(){
      if($(this).hasClass("revertPiece")){
        $(this).removeClass("revertPiece");
        return true;
      } else {
        return false;
      };
    }
  });

  $(".droppable").droppable({
    drop: function(event,ui){

      var x = $(this).data("x");
      var y = $(this).data("y");
      var pieceId = ui.draggable.data("piece");
      var url = ui.draggable[0].baseURI + "/pieces/" + pieceId;
      var token = $('meta[name="csrf-token"]').attr('content');
      var piece_destination = event.target;

      ui.draggable.position( {
        my: "center center",
        at: "center center",
        of: piece_destination
      });

      $.ajax({
        url: url,
        async: false, // considered bad practice, but couldn't figure out any other way :(
        type: 'PUT',
        headers: { 'X-CSRF-Token': token },
        idOfPiece: pieceId,
        pieceDest: piece_destination,
        data: { piece: { location_x: x, location_y: y, has_moved: true } },
        success: function(data, textStatus, jqXHR){
          var piece_id = this.idOfPiece;
          $("#piece_" + piece_id).attr("data-moved","true");

          var piece_dest = this.pieceDest;

          if ( $(piece_dest)[0].childNodes[0] ){
            var piece_at_target = $(piece_dest)[0].childNodes[0].id;
            var piece_at_target_white = $(piece_dest)[0].childNodes[0].attributes[4].value;
            var moving_piece_white = $("#piece_" + piece_id)[0].attributes[4].value;

            if (piece_at_target_white != moving_piece_white){
              $("#" + piece_at_target).effect("shake", {direction: "right", times: 5, distance: 30}, 1000).fadeOut();
            };
          };
        },
        error: function(jqXHR, textStatus, errorMsg){
          var piece_id = this.idOfPiece;
          $("#piece_" + piece_id).addClass("revertPiece"); 
        }
      });
    }
  });

  // The 4 functions below are called when the players click their Castling buttons

  $(".ks-white").click(function castleWhiteKingside(){
    var whiteKsRookId = $("div").find(`[data-x='0'][data-y='0']`)[0].children[0].dataset.piece;
    var whiteKingId = $("div").find(`[data-x='3'][data-y='0']`)[0].children[0].dataset.piece;

    $("#piece_" + whiteKsRookId).animate({left: "+=160"},1000);
    $("#piece_" + whiteKsRookId).attr("data-moved","true");

    $("#piece_" + whiteKingId).animate({right: "+=160"},1000);
    $("#piece_" + whiteKingId).attr("data-moved","true");
  });

  $(".qs-white").click(function castleWhiteQueenside(){
    var whiteQsRookId = $("div").find(`[data-x='7'][data-y='0']`)[0].children[0].dataset.piece;
    var whiteKingId = $("div").find(`[data-x='3'][data-y='0']`)[0].children[0].dataset.piece;

    $("#piece_" + whiteQsRookId).animate({right: "+=240"},1000);
    $("#piece_" + whiteQsRookId).attr("data-moved","true");

    $("#piece_" + whiteKingId).animate({left: "+=160"},1000);
    $("#piece_" + whiteKingId).attr("data-moved","true");
  });

  $(".ks-black").click(function castleBlackKingside(){
    var blackKsRookId = $("div").find(`[data-x='0'][data-y='7']`)[0].children[0].dataset.piece;
    var blackKingId = $("div").find(`[data-x='3'][data-y='7']`)[0].children[0].dataset.piece;

    $("#piece_" + blackKsRookId).animate({left: "+=160"},1000);
    $("#piece_" + blackKsRookId).attr("data-moved","true");

    $("#piece_" + blackKingId).animate({right: "+=160"},1000);
    $("#piece_" + blackKingId).attr("data-moved","true");
  });

  $(".qs-black").click(function castleBlackQueenside(){
    var blackQsRookId = $("div").find(`[data-x='7'][data-y='7']`)[0].children[0].dataset.piece;
    var blackKingId = $("div").find(`[data-x='3'][data-y='7']`)[0].children[0].dataset.piece;

    $("#piece_" + blackQsRookId).animate({right: "+=240"},1000);
    $("#piece_" + blackQsRookId).attr("data-moved","true");

    $("#piece_" + blackKingId).animate({left: "+=160"},1000);
    $("#piece_" + blackKingId).attr("data-moved","true");
  });
});



