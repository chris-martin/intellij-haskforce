package com.haskforce.codeInsight

import com.intellij.openapi.module.{Module, ModuleUtilCore}
import com.intellij.psi.PsiFile

import com.haskforce.highlighting.annotation.external.{GhcMod, GhcModi}
import com.haskforce.utils.ExecUtil

object VisibleModulesProviderFactory {
  def get(psiFile: PsiFile): Option[VisibleModulesProvider] = {
    GhcModiVisibleModulesProvider.create(psiFile).orElse(
      GhcModVisibleModulesProvider.create(psiFile)
    )
  }
}

trait VisibleModulesProvider {
  def getVisibleModules: Array[String]
}

class GhcModiVisibleModulesProvider(
  ghcModi: GhcModi
) extends VisibleModulesProvider {

  override def getVisibleModules: Array[String] = ghcModi.unsafeList()
}

object GhcModiVisibleModulesProvider {
  def create(psiFile: PsiFile): Option[GhcModiVisibleModulesProvider] = for {
    ghcModi <- GhcModi.get(psiFile)
  } yield new GhcModiVisibleModulesProvider(ghcModi)
}

class GhcModVisibleModulesProvider(
  module: Module,
  workDir: String
) extends VisibleModulesProvider {

  override def getVisibleModules: Array[String] = GhcMod.list(module, workDir)
}

object GhcModVisibleModulesProvider {
  def create(psiFile: PsiFile): Option[GhcModVisibleModulesProvider] = for {
    module <- Option(ModuleUtilCore.findModuleForPsiElement(psiFile))
    workDir <- Option(ExecUtil.guessWorkDir(module))
  } yield new GhcModVisibleModulesProvider(module, workDir)
}
