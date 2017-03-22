   function create(htmlStr) {
       var frag = document.createDocumentFragment(),
           temp = document.createElement('div');
       temp.innerHTML = htmlStr;
       while (temp.firstChild) {
           frag.appendChild(temp.firstChild);
       }
       return frag;
   }

   function getFragment(obj, percent, fullname, duedate, days) {
       var border = "white";
       if (obj.status == 'green') {
           border = "success"
       } else if (obj.status == 'red') {
           border = "warning"
       } else if (obj.status == 'amber') {
           border = "danger"
       }

       var now = new Date();
       if (duedate !== null)
       {
          duedateArray =  duedate.split("-");
          var utcDate = new Date(Date.UTC(parseInt(duedateArray[0]), parseInt(duedateArray[1])-1, parseInt(duedateArray[2]), 0, 0, 0));
          var showthumb = "";
          if(utcDate>now) {showthumb="none"};
       } else {
        duedate = "TBA";
        showthumb="none";
       }
       
       var frag = '<div class="col-xs-6 col-sm-3 placeholder"> <canvas id="canvas-' 
           + obj.id + '"></canvas>  <h3 title="' + obj.epic +'" style="white-space: nowrap;text-overflow: ellipsis;overflow: hidden;">' 
           + obj.epic + '</h3> <span class="text-muted"> <i class="fa fa-calendar" aria-hidden="true"></i> : ' 
           + duedate +
           ' <i style="color:LimeGreen;display:'+showthumb+'" class="fa fa-thumbs-o-up" aria-hidden="true"></i>' 
           + '</span> ' +
           '    <div class="table-responsive">' +
           '            <table class="table table-striped">' +
           '              <tbody>'
           // +'                <tr>'
           // +'                  <th>Team Lead</th>'
           // +'                  <td>'+obj.teamlead+'</td>'
           // +'                </tr>'
           // +'                <tr>'
           // +'                  <th>Tech Lead</th>'
           // +'                  <td>'+obj.techlead+'</td>'
           // +'                </tr>'
           +
           '                <tr>' +
           '                  <th>Status</th>' +
           '                  <td><span class="label label-' + border + '" style="color: transparent;">status</span></td>' +
           '                </tr>' +
           '                <tr>' +
           '                  <th>Completion</th>' +
           '                  <td>' + percent + '%</td>' +
           '                </tr>' +
           '                <tr>' +
           '                  <th>Product Owner</th>' +
           '                  <td>' + fullname + '</td>' +
           '                </tr>'
           // +'                <tr>'
           // +'                  <th>CET</th>'
           // +'                  <td>'+obj.CET+'</td>'
           // +'                </tr>'
           +
           '              </tbody>' +
           '            </table>' +
           // '<div class="comment" style="height:90px">' + obj.comment + '</div>' +
           '          </div></div>';
       return frag;
   }

   $.ajax({
       url: 'entities.json',
       dataType: 'json',
       async: false,
       success: function(data) {
           // console.log(data);
           data.forEach(function(obj) {
               var newUrl = obj.id + '.json';
               // console.log(newUrl);
               $.ajax({
                   url: obj.id + '.json',
                   dataType: 'json',
                   async: false,
                   success: function(entity) {
                    // console.log(entity);
                       var percent = ((entity[10].value / entity[10].total) * 100).toFixed(2);
                       var fullname = entity[0].fullname;
                       var duedate = entity[0].duedate;
                       var fragment = create(getFragment(obj, percent, fullname, duedate, 2));
                       var childsNr = document.getElementById('pie').childNodes;
                       document.getElementById("pie").insertBefore(fragment, document.getElementById("pie").childNodes[childsNr.length]);
                       var ctx = document.getElementById("canvas-" + obj.id).getContext("2d");
                       ctx.canvas.style.width = "150px";
                       ctx.canvas.style.height = "150px";
                       var myPie = new Chart(ctx).Doughnut(entity);

                   }
               }).fail(function(data, status, er) {
                   console.log("error: " + data + " status: " + status + " er:" + er);
               });

           });
       }
   });

   $(document).ready(function() {

       $(".comment").shorten({
           "showChars": 50,
           "moreText": "See More",
           "lessText": "Less",
       });

   });