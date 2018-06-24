$(function() {

  $(".draggable").draggable({ containment: '.chessboard' });

  $(".droppable").droppable( {
    drop: function( event, ui ) {
      var x = $(this).data("x");
      var y = $(this).data("y");
      var pieceId = ui.draggable.data("piece");
      var url = ui.draggable[0].baseURI + "/pieces/" + pieceId;
      var token = $('meta[name="csrf-token"]').attr('content');
      var piece_target = event.target;

      ui.draggable.position( {
        my: "center",
        at: "center",
        of: piece_target
      });

      $.ajax({
        url: url,
        type: 'PUT',
        headers: { 'X-CSRF-Token': token },
        data: { piece: { location_x: x, location_y: y } }
      });
    }
  });
});

