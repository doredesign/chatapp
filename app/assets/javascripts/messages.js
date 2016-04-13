(function($){
  $(function() {
    var eventBus = new vertx.EventBus("/eventbus"),
        $updates = $("#updates"),
        userName = $updates.data('current-user');

    eventBus.onopen = function() {
      eventBus.send("login", userName, function(data){
        for(var i = 0; i < data.users.length; i++) {
          if (data.users[i] != userName) $("#receivers").append("<option>" + data.users[i] + "</option>");
        }
      });

      $updates.html("<h5>Welcome to the Jubilee chat room!</h5>");

      eventBus.registerHandler("chat", function(data) {
        if (data.sender != userName)
          $updates.append("<div class='public'><span class='sender'>" + data.sender + " said:</span>" + data.message + "</div>");
        else
          $updates.append("<div class='public by_you'><span class='sender'>You said:</span>" + data.message + "</div>");
      });

      eventBus.registerHandler("new_user", function(data) {
        if (data != userName) {
          $("#receivers").append("<option>" + data + "</option");
          $updates.append("<div class='login'>" + data + " joined the room.</div>");
        }
      });

      eventBus.registerHandler(userName, function(data) {
        $updates.append("<div class='private'><span class='sender'>" + data.sender + " said to you:</span>" + data.message + "</div>");
      });

      eventBus.registerHandler("logout", function(data) {
        $('#receivers option:contains("' + data + '")').remove();
        $updates.append("<div class='logout'>" + data + " left the room.</div>");
      });

      window.onbeforeunload = function() {
        eventBus.publish("logout", userName);
      };
    };

    var sendMessage = function() {
      var msg = $("#content").val();
      if ((receiver = $("#receivers").val()) === "all") {
        eventBus.publish("chat", {sender: userName, message: msg});
      } else {
        $updates.append("<div class='public by_you'><span class='sender'>You said to " + receiver + ":</span>" + msg + "</div>");
        eventBus.send(receiver, {sender: userName, message: msg});
      }
      $("#content").val("");
    };

    $("#send").click(sendMessage);

    $(document.body).keyup(function(ev) {
      if (ev.which === 13) {
        sendMessage();
      }
    });
  });
})(jQuery);
