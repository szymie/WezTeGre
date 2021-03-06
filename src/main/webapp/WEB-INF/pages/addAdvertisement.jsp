<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page session="false" %>
<!doctype html>
<html>
<head>
        <title>Dodaj ogłoszenie</title>

        <script type="application/javascript" src="<c:url value="/resources/jquery-1.11.2.min.js" />"></script>
        <script type="application/javascript" src="<c:url value="/resources/jquery.form.js" />"></script>
        <script type="application/javascript">
                $(function () {
                        var url = "<c:url value="" />";

                        function addNewGame() {
                                var trToAdd = "<tr>" +
                                                "<td class='game'>" + $("tr.game select").parent().html() + "</td>" +
                                                "<td class='platform'>" + $("tr.platform select").parent().html() + "</td>" +
                                                "<td class='language'>" + $("tr.language select").parent().html() + "</td>" +
                                                "<td class='distribution'>" + $("tr.distribution select").parent().html() + "</td>" +
                                                "<td><button type='button' class='remove'>Usuń</button></td>" +
                                                "</tr>";
                                $(trToAdd).insertBefore("table#games tr:last-child");
                        }
                        addNewGame();

                        $("button#addNew").click(function() {
                                addNewGame();
                        });

                        $(document).on("click", "button.remove", function() {
                                var index = $("table#games tr").index($(this).parent().parent());
                                if($("table#games tr").length > 3)
                                        $("table#games tr:nth-child(" + (index + 1) + ")").remove();
                        });

                        $(document).on("click", "button.removePhoto", function() {
                                var index = $("table#photos tr").index($(this).parent().parent());
                                $("table#photos tr:nth-child(" + (index + 1) + ")").remove();
                        });

                        $("button#uploadPhoto").click(function() {
                                $("#form").ajaxForm({
                                        success:function(result) {
                                                var img = "<img src='" + result + "' width='150px' />";

                                                var photoTr = "<tr>" +
                                                                "<td>" + img + "</td>" +
                                                                "<td>" + "<button type='button' class='removePhoto'>Usuń</button>" + "</td>"
                                                                "</tr>";
                                                $("table#photos").append(photoTr);
                                        }
                                }).submit();

                                var control = $("#form input");
                                control.replaceWith( control = control.clone(true) );
                        });

                        $("#send").click(function () {
                                var length = $("table#games tr").length;
                                var gamesForExchange = [];
                                $("table#games tr").each(function(index, value) {
                                        if(index > 0 && index < length - 1) {
                                                var game = {};
                                                game.game = { id: $(this).find(".game option:selected").val() };
                                                game.platform = $(this).find(".platform option:selected").text();
                                                game.language = $(this).find(".language option:selected").text();
                                                game.distribution = $(this).find(".distribution option:selected").text();

                                                gamesForExchange.push(game);
                                        }
                                });

                                length = $("table#photos tr").length;
                                var photos = [];
                                $("table#photos tr").each(function(index, value) {
                                                var photo = { photo: $(this).find("img").attr("src") };

                                                photos.push(photo);
                                });

                                var dataForm = (JSON.stringify({
                                        title: $("tr#title input[name='title']").val(),
                                        content: $("tr#content textarea[name='content']").val(),
                                        game: { id: $("tr.game option:selected").val() },
                                        state: $("tr#state option:selected").text(),
                                        platform: $("tr.platform option:selected").text(),
                                        language: $("tr.language option:selected").text(),
                                        distribution: $("tr.distribution option:selected").text(),
                                        gamesForExchange: gamesForExchange,
                                        photos: photos
                                }));

                                var dataForm1 = {
                                        title: $("tr#title input[name='title']").val(),
                                        content: $("tr#content textarea[name='content']").val(),
                                        game: {id: $("tr.game option:selected").val()},
                                        state: $("tr#state option:selected").text(),
                                        platform: $("tr.platform option:selected").text(),
                                        language: $("tr.language option:selected").text(),
                                        distribution: $("tr.distribution option:selected").text(),
                                        gamesForExchange: gamesForExchange,
                                        photos: photos
                                };

                                $.ajax({
                                        type: "POST",
                                        headers: {
                                                'Accept': 'application/json',
                                                'Content-Type': 'application/json'
                                        },
                                        url: "<c:url value="/advertisement/add" />",
                                        data: dataForm,
                                        dataType: "json",
                                        success: function(result) {
                                                if(result.redirect == null) {
                                                        $("table .error").remove();

                                                        if(result.titleError != null)
                                                                $("table tr#title").append("<td class='error'>" + result.titleError + "</td>");

                                                        if(result.contentError != null)
                                                                $("table tr#content").append("<td class='error'>" + result.contentError + "</td>");
                                                } else {
                                                        window.location.replace(url + "/" + result.redirect);
                                                }
                                        }
                                })
                        });
                });
        </script>
</head>
<body>
        <table>
                <tr id="title">
                        <td>Tytuł:</td>
                        <td><input type="text" name="title"/></td>
                </tr>
                <tr id="content">
                        <td>Opis:</td>
                        <td><textarea name="content" rows="10"></textarea></td>
                </tr>
                <tr class="game">
                        <td>Gra:</td>
                        <td>
                                <select name="game">
                                        <c:forEach items="${games}" var="item">
                                                <option value="${item.id}">${item}</option>
                                        </c:forEach>
                                </select>
                        </td>
                </tr>
                <tr id="state">
                        <td>Stan:</td>
                        <td>
                                <select name="state">
                                        <c:forEach items="${states}" var="item">
                                                <option value="${item}">${item}</option>
                                        </c:forEach>
                                </select>
                        </td>
                </tr>
                <tr class="platform">
                        <td>Platforma:</td>
                        <td>
                                <select name="platform">
                                        <c:forEach items="${platforms}" var="item">
                                                <option value="${item}">${item}</option>
                                        </c:forEach>
                                </select>
                        </td>
                </tr>
                <tr class="language">
                        <td>Język:</td>
                        <td>
                                <select name="language">
                                        <c:forEach items="${languages}" var="item">
                                                <option value="${item}">${item}</option>
                                        </c:forEach>
                                </select>
                        </td>
                </tr>
                <tr class="distribution">
                        <td>Nośnik:</td>
                        <td>
                                <select name="distribution">
                                        <c:forEach items="${distributions}" var="item">
                                                <option value="${item}">${item}</option>
                                        </c:forEach>
                                </select>
                        </td>
                </tr>
        </table>
        <hr />
        Poszukiwane gry:
        <table id="games">
                <tr>
                        <td>Nazwa</td>
                        <td>Platforma</td>
                        <td>Język</td>
                        <td>Nośnik</td>
                        <td></td>
                </tr>

                <tr>
                        <td colspan="5">
                                <button type="button" id="addNew">Dodaj nową</button>
                        </td>
                </tr>
        </table>
        <hr />

        Zdjęcia:
        <form id="form" method="POST" action="<c:url value="/advertisement/upload" />" enctype="multipart/form-data">
                <input name="file" id="file" type="file" />
        </form>
        <button type="button" id="uploadPhoto" >Dodaj zdjęcie</button>

        <table id="photos">

        </table>

        <hr />
        <button type="button" id="send">Dodaj ogłoszenie</button>
</body>
</html>
