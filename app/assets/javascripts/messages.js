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
        $typingDiv = $("#typing"),
        userIsActive = true;

    eventBus.onopen = function() {
      eventBus.send("login", currentUser, function(data){
        for(var i = 0; i < data.users.length; i++) {
          if (data.users[i] !== currentUser) $("#receivers").append("<option>" + data.users[i] + "</option>");
        }
      });

      $updates.html("<h5>Welcome to the Jubilee chat room!</h5>");

      eventBus.registerHandler("chat", function(data) {
        if (data.sender != currentUser)
          appendInChat("public", "<span class='sender'>" + data.sender + " said:</span>" + data.message);
        else
          appendInChat("public by_you", "<span class='sender'>You said:</span>" + data.message);
      });

      eventBus.registerHandler("new_user", function(newUser) {
        if (newUser === currentUser) return;

        $("#receivers").append("<option>" + newUser + "</option");
        appendInChat("login", newUser + " joined the room.");
      });

      eventBus.registerHandler(currentUser, function(data) {
        appendInChat("private", "<span class='sender'>" + data.sender + " said to you:</span>" + data.message);
      });

      eventBus.registerHandler("logout", function(loggedOutUser) {
        $('#receivers option:contains("' + loggedOutUser + '")').remove();
        appendInChat("logout", loggedOutUser + " left the room.");
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
        appendInChat("public by_you", "<span class='sender'>You said to " + receiver + ":</span>");
        eventBus.publish(receiver, {sender: currentUser, message: msg});
      }
      $content.val("");
      markAllAsRead();
    };

    var appendInChat = function(klass, html){
      klass += userIsActive ? '' : ' unread';
      $updates.append("<div class='" + klass + "'>" + html + "</div>");
    };

    var userTyped = function(event){
      eventBus.publish("typing", currentUser);
    };

    var userLeft = function(){
      userIsActive = false;
    };

    var userReturned = function(){
      userIsActive = true;
      identifyUnreadMessages();
    };

    var identifyUnreadMessages = function(){
      if ( $('.unread_notification').length > 0 ) return;

      var $firstUnreadMessage = $updates.find('.unread').first();
      $firstUnreadMessage.before("<div class='unread_notification'><h4>Unread messages</h4><a href='#' class='mark-as-read'>Mark as read</a></div>");
    };

    var markAllAsRead = function(){
      $('.unread_notification').remove();
      $updates.find('.unread').removeClass('unread');
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

    $(window).on('blur', userLeft);
    $(window).on('focus', userReturned);

    $('#updates').on('click', '.mark-as-read', function(event){
      event.preventDefault();
      markAllAsRead();
    });
  });
})(jQuery, _);
