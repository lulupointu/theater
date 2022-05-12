package com.theater.intellij.live_templates

import com.intellij.codeInsight.template.impl.DefaultLiveTemplatesProvider

class BlocTemplateProvider : DefaultLiveTemplatesProvider {
    override fun getDefaultLiveTemplateFiles(): Array<String> {
        return arrayOf("liveTemplates/Theater")
    }

    override fun getHiddenLiveTemplateFiles(): Array<String>? {
        return null
    }
}