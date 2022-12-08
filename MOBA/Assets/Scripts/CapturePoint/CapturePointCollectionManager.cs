using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CapturePoint
{
public class CapturePointCollectionManager : MonoBehaviour
{
   public CapturePoint[] GoldCapturePoints;
   public CapturePoint[] VictoryCapturePoints;

   public static CapturePointCollectionManager instance ;
   private void Awake()
   {
      instance = this;
   }
}
}
