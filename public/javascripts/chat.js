$(function(){
  const Message = Backbone.Model.extend({

  });

  const MessageCollection = Backbone.Collection.extend({
    model: Message
  });

  const currentMessage = new Message({
    user: currentUser
  });

  const messages = new MessageCollection();

  const ws = new WebSocket(`ws://localhost:3000/ws/chat?room_name=${roomName}`);

  function emit(name, data){
    ws.send(JSON.stringify({
      event: name,
      data: data,
      socketid: ws.sid
    }));
  }

  $("#message-input").keyup(function(ev){
    currentMessage.set('message', ev.target.value);
  });

  $(".send-message-btn").click(function(ev){
    ev.preventDefault();

    if(_.isEmpty(currentMessage.get('message'))) {
      return;
    }

    messages.add(currentMessage.toJSON());
    emit("message", currentMessage.toJSON());

    currentMessage.set('message', "");
    $("#message-input").val("");
  });

  var compile = _.template($("#chat-cell").html());
  messages.on('add', function(message){
    $(".msg-wrap").append(compile({message: message}));
  });


  ws.onopen = function() {
    console.log('Connected');
  };

  ws.onmessage = function(evt) {
    var data = JSON.parse(evt.data);
    switch(data.event) {
      case "connect":
        ws.sid = data.socketid;
        break;
      case "message":
        messages.add(data.data);
        break;
    }
  };
});
