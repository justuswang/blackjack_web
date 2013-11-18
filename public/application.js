$(document).on("click", "div#player_hit", function() {
    $.ajax({
        type: 'POST',
        url: '/game/player/hit'
    }).done(function(msg) {
        $("div#game").replaceWith(msg);
    });
    return false;
});

$(document).on("click", "div#player_stay", function() {
    $.ajax({
        type: 'POST',
        url: '/game/player/stay'
    }).done(function(msg) {
        $("div#game").replaceWith(msg);
    });
    return false;
});

$(document).on("click", "div#dealer_hit", function() {
    $.ajax({
        type: 'POST',
        url: '/game/dealer/hit'
    }).done(function(msg) {
        $("div#game").replaceWith(msg);
    });
    return false;
});


// $(document).on("click", "form#hit_form input", function() {
//     $.ajax({
//         type: 'POST'
//         url: '/game/player/hit'
//     }).done(function(msg) {
//         $("div#game").replaceWith(msg);
//     });
//     return false;
// });

// $(document).on("click", "form#stay_form input", function() {
//     $.ajax({
//         type: 'POST'
//         url: '/game/player/stay'
//     }).done(function(msg) {
//         $("div#game").replaceWith(msg);
//     });
//     return false;
// });

// $(document).on("click", "form#dealer_hit_form input", function() {
//     $.ajax({
//         type: 'POST'
//         url: '/game/dealer/hit'
//     }).done(function(msg) {
//         $("div#game").replaceWith(msg);
//     });
//     return false;
// });