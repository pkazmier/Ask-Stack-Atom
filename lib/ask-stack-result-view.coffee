{$, $$$, ScrollView} = require 'atom'

require './bootstrap/bootstrap.min.js'

module.exports =
class AskStackResultView extends ScrollView
  @content: ->
    @div class: 'ask-stack-result native-key-bindings', tabindex: -1

  initialize: ->
      super

  destroy: ->
    @unsubscribe()

  getTitle: ->
    "Ask Stack Results"

  getUri: ->
    "ask-stack://result-view"

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  renderAnswers: (answersJson) ->
    html = ''

    for question in answersJson['items']
      questionHtml = @renderQuestionHeader(question)
      html += questionHtml

    @html(html)

    @renderQuestionBody(answersJson['items'][0])
    @renderQuestionBody(answersJson['items'][1])
    @renderQuestionBody(answersJson['items'][2])

  renderQuestionHeader: (question) ->
    html = "
    <div class=\"ui-result\" id=\"#{question['question_id']}\">
      <h2 class=\"title\">
      <a class=\"underline title-string\" href=\"#{question['link']}\">
        #{question['title']}
      </a>
      <div class=\"score\"><p>#{question['score']}</p></div>
    </h2>
    <div class=\"created\">
      #{new Date(question['creation_date'] * 1000).toLocaleString()}
    </div>
    <div class=\"tags\">"
    for tag in question['tags']
      html += "<span class=\"label label-info\">#{tag}</span>\n"
    html += "</div>
    </div>"

  renderQuestionBody: (question) ->
    curAnswer = 0
    div = document.createElement('div');
    div.innerHTML = "
    <ul class=\"nav nav-tabs nav-justified\">
      <li class=\"active\"><a href=\"#question\" data-toggle=\"tab\">Question</a></li>
      <li><a href=\"#answers-#{question['question_id']}\" data-toggle=\"tab\">Answers</a></li>
    </ul>
    <div class=\"tab-content\">
      <div class=\"tab-pane active\" id=\"question\">#{question['body']}</div>
      <div class=\"tab-pane\" id=\"answers-#{question['question_id']}\">
        <center><a href=\"#prev#{question['question_id']}\"><< Prev</a>   <span id=\"curAnswer-#{question['question_id']}\">#{curAnswer+1}</span>/#{question['answers'].length}  <a href=\"#next#{question['question_id']}\">Next >></a> </center>
      </div>
    </div>"
    document.getElementById("#{question['question_id']}").appendChild(div)
    @addCodeButtons(question['question_id'])

    @renderAnswerBody(question['answers'][curAnswer], question['question_id'])


    $("a[href=\"#next#{question['question_id']}\"]").click (event) =>
        if curAnswer+1 >= question['answers'].length then curAnswer = 0 else curAnswer += 1
        $("#answers-#{question['question_id']}").children().last().remove()
        $("#curAnswer-#{question['question_id']}")[0].innerText = curAnswer+1
        @renderAnswerBody(question['answers'][curAnswer], question['question_id'])

    $("a[href=\"#prev#{question['question_id']}\"]").click (event) =>
        if curAnswer-1 < 0 then curAnswer = question['answers'].length-1 else curAnswer -= 1
        $("#answers-#{question['question_id']}").children().last().remove()
        $("#curAnswer-#{question['question_id']}")[0].innerText = curAnswer+1
        @renderAnswerBody(question['answers'][curAnswer], question['question_id'])

  renderAnswerBody: (answer, question_id) ->
    div = $("<div></div>").append(answer['body'])
    $("#answers-#{question_id}").append(div)
    @addCodeButtons("answers-#{question_id}")

  addCodeButtons: (elem_id) ->
    pres = document.getElementById(elem_id).getElementsByTagName('pre');
    #pres = $(elem).siblings('pre')
    for pre in pres
      btnInsert = @genButton('Insert')
      btnCopy = @genButton('Copy')
      $(pre).prev().after(btnInsert)
      $(pre).prev().after(btnCopy)

  genButton: (text) ->
    $('<button/>',
    {
        text: text,
        class: 'btn btn-default btn-xs'
    })
