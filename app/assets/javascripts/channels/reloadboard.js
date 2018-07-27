App.locations = App.cable.subscriptions.create('PiecesChannel', {
  received: function(data) {
    var path = '/games/' + data.game_id + '/reload_board'
    $('.reloadboard').load(path);
  }
});