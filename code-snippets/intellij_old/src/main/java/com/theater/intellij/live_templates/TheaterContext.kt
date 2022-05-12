package com.theater.intellij.live_templates

import com.intellij.codeInsight.template.TemplateContextType
import com.intellij.psi.PsiFile

class TheaterContext : TemplateContextType("Theater", "Theater") {
    override fun isInContext(file: PsiFile, offset: Int): Boolean {
        return file.name.endsWith(".dart")
    }
}