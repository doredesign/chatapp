(function($, _){
  var typingState = (function(){
    var typingUsers = {},
        typingEventWait = 2000,
        typingEventThrottle = 1500,
        $typingDiv = $("#typing");

    var userTyping = function(user){
      if (typingUsers[user] === undefined){
        setUserTimeout(user);
        updateUi();
      } else {
        window.clearTimeout(typingUsers[user]);
        setUserTimeout(user);
      }
    };

    var userStoppedTyping = function(user){
      delete typingUsers[user];
      updateUi();
    };

    var setUserTimeout = function(user){
      typingUsers[user] = window.setTimeout(function(){
        userStoppedTyping(user);
      }, typingEventWait);
    };

    var updateUi = function(){
      var typingUserNames = Object.keys(typingUsers),
          typingUsersCount = typingUserNames.length;
      if (typingUsersCount > 1){
        $typingDiv.text('Multiple users are typing');
      } else if (typingUsersCount === 1){
        $typingDiv.text(typingUserNames[0] + ' is typing');
      } else {
        $typingDiv.text('');
      }
    };

    return {
      userTyping: userTyping,
      typingEventThrottle: typingEventThrottle
    };
  })();



  $(function() {
    var eventBus = new vertx.EventBus("/eventbus"),
        $updates = $("#updates"),
        $content = $("#content"),
        currentUser = $updates.data('current-user'),
        $typingDiv = $("#typing");

    eventBus.onopen = function() {
      eventBus.send("login", currentUser, function(data){
        for(var i = 0; i < data.users.length; i++) {
          if (data.users[i] !== currentUser) $("#receivers").append("<option>" + data.users[i] + "</option>");
        }
      });

      $updates.html("<h5>Welcome to the Jubilee chat room!</h5>");

      eventBus.registerHandler("chat", function(data) {
        if (data.sender != currentUser)
          $updates.append("<div class='public'><span class='sender'>" + data.sender + " said:</span>" + data.message + "</div>");
        else
          $updates.append("<div class='public by_you'><span class='sender'>You said:</span>" + data.message + "</div>");
      });

      eventBus.registerHandler("new_user", function(newUser) {
        if (newUser !== currentUser) {
          $("#receivers").append("<option>" + newUser + "</option");
          $updates.append("<div class='login'>" + newUser + " joined the room.</div>");
        }
      });

      eventBus.registerHandler(currentUser, function(data) {
        $updates.append("<div class='private'><span class='sender'>" + data.sender + " said to you:</span>" + data.message + "</div>");
      });

      eventBus.registerHandler("logout", function(loggedOutUser) {
        $('#receivers option:contains("' + loggedOutUser + '")').remove();
        $updates.append("<div class='logout'>" + loggedOutUser + " left the room.</div>");
      });

      eventBus.registerHandler("typing", function(currentlyTypingUser) {
        if (currentlyTypingUser !== currentUser) typingState.userTyping(currentlyTypingUser);
      });

      window.onbeforeunload = function() {
        eventBus.publish("logout", currentUser);
      };
    };

    var sendMessage = function() {
      var msg = $content.val();
      if ((receiver = $("#receivers").val()) === "all") {
        eventBus.publish("chat", {sender: currentUser, message: msg});
      } else {
        $updates.append("<div class='public by_you'><span class='sender'>You said to " + receiver + ":</span>" + msg + "</div>");
        eventBus.send(receiver, {sender: currentUser, message: msg});
      }
      $content.val("");
    };

    var userTyped = function(event){
      eventBus.publish("typing", currentUser);
    };

    $("#send").click(sendMessage);

    $(document.body).keyup(function(event) {
      if (event.which === 13) sendMessage();
    });

    $content.keyup(_.throttle(
      userTyped,
      typingState.typingEventThrottle,
      { trailing: false }
    ));
  });
})(jQuery, _);
