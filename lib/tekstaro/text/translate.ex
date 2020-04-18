defmodule Tekstaro.Text.Translate do

  import TekstaroWeb.Gettext

  def translate_verbo(%Verbo{aspecto:        aspecto,
                             estas_partipo:  estas_partipo,
                             estas_perfekto: estas_perfekto,
                             formo:          formo,
                             voĉo:           voĉo}) do
    type        = gettext("Verb.")
    form        = translate_form(formo)
    voice       = translate_voice(voĉo)
    description = [voice, form, type]
    description = case estas_perfekto do
      :jes -> [gettext("Perfect aspect.") | description]
      :ne  -> description
    end
    description = case estas_partipo do
      :jes -> [gettext("It is a") <> translate_aspect(aspecto) <> " " <> gettext("participle.") | description]
      :ne  -> description
    end
    Enum.join(Enum.reverse(description), " ")
  end

  def translate_ovorto(%Ovorto{estas_karesnomo: estas_karesnomo,
                               kazo:            kazo,
                               nombro:          nombro}) do
      is_nickname = case estas_karesnomo do
        :jes -> gettext(" (its a nickname).")
        :ne  -> "."
      end
      type        = gettext("Noun") <> is_nickname
      plural      = translate_number(nombro)
      casemarked  = is(translate_case(kazo), gettext("Case marked."))
      description = [type, plural, casemarked]
      Enum.join(description, " ")
  end

  def translate_evorto(%Evorto{kazo: kazo}) do
    type        = gettext("Adverb.")
    casemarked  = is(translate_case(kazo), gettext("Case marked."))
    description = [type, casemarked]
    Enum.join(description, " ")
  end

  def translate_avorto(%Avorto{kazo:            kazo,
                               nombro:          nombro}) do
      type        = gettext("Adjective.")
      plural      = translate_number(nombro)
      casemarked  = is(translate_case(kazo), gettext("Case marked."))
      description = [type, plural, casemarked]
      Enum.join(description, " ")
  end

  def translate_pronomo(%Pronomo{estas_poseda: estas_karesnomo,
                                 kazo:         kazo,
                                 nombro:       nombro}) do
      type        = gettext("Pronoun.")
      possesive   = is(translate_boolean(estas_karesnomo), gettext("Possesive."))
      plural      = translate_number(nombro)
      casemarked  = is(translate_case(kazo), gettext("Case marked."))
      description = [type, possesive, plural, casemarked]
      Enum.join(description, " ")
  end

  def translate_korelatevo(%Korelatevo{kazo: kazo}) do
        type        = gettext("Correlative.")
        casemarked  = is(translate_case(kazo), gettext("Case marked."))
        description = [type, casemarked]
        Enum.join(description, " ")
  end

  def translate_voice(:aktiva), do: gettext("Active voice.")
  def translate_voice(:pasiva), do: gettext("Passive voice.")

  def translate_aspect(:nil),      do: :nil
  def translate_aspect(:ekestiĝa), do: gettext("an 'in-play'")
  def translate_aspect(:finita),   do: gettext("a 'finished'")
  def translate_aspect(:anticipa), do: gettext("an 'anticipated'")

  def translate_form(:infinitiva), do: gettext("Infinive.")
  def translate_form(:nuna),       do: gettext("Present tense.")
  def translate_form(:futuro),     do: gettext("Future tense.")
  def translate_form(:estinta),    do: gettext("Past tense.")
  def translate_form(:kondiĉa),    do: gettext("Conditional mood.")
  def translate_form(:imperativa), do: gettext("Imperative.")
  def translate_form(:participa),  do: gettext("Participle.")
  def translate_form(:radikigo),   do: gettext("Radical (not being used as a verb).")

  def translate_number(:sola),  do: gettext("Singular.")
  def translate_number(:plura), do: gettext("Plural.")

  def translate_case(:markita),    do: true
  def translate_case(:malmarkita), do: false

  def translate_boolean(:ne),  do: false
  def translate_boolean(:jes), do: true

  defp is(true,  string),  do: string
  defp is(false, _string), do: ""

end
