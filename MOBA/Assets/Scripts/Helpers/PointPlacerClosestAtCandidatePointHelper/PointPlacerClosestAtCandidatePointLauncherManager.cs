using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PointPlacerClosestAtCandidatePointHelper
{
public class PointPlacerClosestAtCandidatePointLauncherManager : MonoBehaviour
{

 public PointPlacerClosestAtCandidatePointLauncher GetLauncher => launcher;
 [SerializeField]
 private PointPlacerClosestAtCandidatePointLauncher launcher;
 public static PointPlacerClosestAtCandidatePointLauncherManager instance;

 private void Awake()
 {
  instance = this;
  launcher = new PointPlacerClosestAtCandidatePointLauncher();
 }

 private void OnDrawGizmosSelected()
 {
  for (int i = 0; i < launcher.placer.candidatesPoint.Count; i++)
  {
   Gizmos.color = Color.green;
   Gizmos.DrawSphere(launcher.placer.candidatesPoint[i], 0.5f);
  }
  
  
 }
}
}
