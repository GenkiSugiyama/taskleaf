document.addEventListener('turbolinks:load', function() {
  document.querySelectorAll('td').forEach(function(td){
    td.addEventListener('mouseover', function(e) {
      e.currentTarget.style.backgroundColor = '#eff';
    });

    td.addEventListener('mouseout', function(e) {
      e.currentTarget.style.backgroundColor = '';
    });
  });
});

// タスク一覧画面の削除ボタンが押されたら該当要素を非表示にする処理
// document.addEventListener('turbolinks:load', function() {
//   document.querySelectorAll('.delete').forEach(function(a) {
//     a.addEventListener('ajax:success', function() {
//       var td = a.parentNode;
//       var tr = td.parentNode;
//       tr.style.display = 'none';
//     });
//   });
// });