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
    var eventBus     = new vertx.EventBus("/eventbus"),
        $updates     = $("#updates"),
        $content     = $("#content"),
        currentUser  = $updates.data('current-user'),
        $typingDiv   = $("#typing"),
        currentRoom  = $('#current-room').text(),
        userIsActive = true;

    eventBus.onopen = function() {
      $updates.html("<h5>Howdy! You're in the " + currentRoom + " room.</h5>");

      eventBus.registerHandler(currentRoom + "-chat", function(data) {
        if (data.sender != currentUser)
          appendInChat("public", "<span class='sender'>" + data.sender + " said:</span>" + data.message);
        else
          appendInChat("public by_you", "<span class='sender'>You said:</span>" + data.message);
      });

      eventBus.registerHandler("login", function(data) {
        if (data.room !== currentRoom || data.sender === currentUser) return;

        $("#receivers").append("<option>" + data.sender + "</option");
        appendInChat("login", data.sender + " joined the room.");
      });

      eventBus.registerHandler(currentRoom + "-" + currentUser, function(data) {
        appendInChat("private", "<span class='sender'>" + data.sender + " said to you:</span>" + data.message);
      });

      eventBus.registerHandler("logout", function(data) {
        if (data.room !== currentRoom) return;

        $('#receivers option:contains("' + data.sender + '")').remove();
        appendInChat("logout", data.sender + " left the room.");
      });

      eventBus.registerHandler(currentRoom + "-typing", function(currentlyTypingUser) {
        if (currentlyTypingUser !== currentUser) typingState.userTyping(currentlyTypingUser);
      });

      window.onbeforeunload = function() {
        eventBus.publish("logout", {sender: currentUser, room: currentRoom});
      };

      eventBus.publish("login", {sender: currentUser, room: currentRoom});
    };

    var sendMessage = function() {
      var msg = $content.val();
      if ((receiver = $("#receivers").val()) === "all") {
        eventBus.publish(currentRoom + "-chat", {sender: currentUser, message: msg});
      } else {
        appendInChat("public by_you", "<span class='sender'>You said to " + receiver + ":</span>" + msg);
        eventBus.publish(currentRoom + "-" + receiver, {sender: currentUser, message: msg});
      }
      $content.val("");
      markAllAsRead();
    };

    var appendInChat = function(klass, html){
      klass += userIsActive ? '' : ' unread';
      $updates.append("<div class='" + klass + "'>" + html + "</div>");
    };

    var userTyped = function(event){
      eventBus.publish(currentRoom + "-typing", currentUser);
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
