using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Champion;
using Photon.Pun;
using UnityEngine;

namespace CapturePoint
{
public class CapturePointWithInner : CapturePoint
{
   private List<Champion> firstTeamChampionInInnerPoint = new List<Champion>();
   private List<Champion> secondTeamChampionInInnerPoint = new List<Champion>();
   [SerializeField]
   private float innerRangeSquared;
   private CapturePointWithInnerSO _capturePointWithInnerSo;
   Enums.CapturePointResolveType innerPointResolveType;
   [SerializeField] private MeshRenderer innerRenderer;
   protected override void OnStart()
   {
      base.OnStart();

      if (capturePointSO)
      {
         _capturePointWithInnerSo =(CapturePointWithInnerSO) capturePointSO;
      innerRangeSquared = _capturePointWithInnerSo.innerPointRange * _capturePointWithInnerSo.innerPointRange;
      if (innerRenderer)
      {
         innerRenderer.transform.SetGlobalScale(new Vector3(1,0,1) *2* _capturePointWithInnerSo.innerPointRange+Vector3.up);
      }
      }
   }

   void OnValidate()
   {
      if (capturePointSO)
      {
      _capturePointWithInnerSo =(CapturePointWithInnerSO) capturePointSO;

      }
      

   }

   private void OnDrawGizmosSelected()
   {
      Gizmos.color = Color.red;
      if (capturePointSO)
      {
         Gizmos.DrawWireSphere(transform.position, _capturePointWithInnerSo.innerPointRange);
      }

   }

   protected override void ResolveTeamSupremacy()
   {
 
      if (secondTeamChampionInInnerPoint.Count == 0 && firstTeamChampionInInnerPoint.Count == 0)
      {
         innerPointResolveType = Enums.CapturePointResolveType.None;
      }
      else if (secondTeamChampionInInnerPoint.Count != 0 && firstTeamChampionInInnerPoint.Count == 0)
      {
         innerPointResolveType = Enums.CapturePointResolveType.Team2;
      }
      else if (secondTeamChampionInInnerPoint.Count == 0 && firstTeamChampionInInnerPoint.Count != 0)
      {
         innerPointResolveType = Enums.CapturePointResolveType.Team1;
      }
      else if(secondTeamChampionInInnerPoint.Count != 0 && firstTeamChampionInInnerPoint.Count != 0)
      {
         innerPointResolveType = Enums.CapturePointResolveType.Conflict;
      }

      if (innerPointResolveType != Enums.CapturePointResolveType.None)
      {
         capturePointResolve = innerPointResolveType;
         UpdateCapturePointDirection();
         return;
      };
      base.ResolveTeamSupremacy();
      
   }

   public override void RemoveFirstTeamChampion(Champion champion)
   {
      base.RemoveFirstTeamChampion(champion);
      firstTeamChampionInInnerPoint.Remove(champion);
   }

   public override void RemoveSecondTeamChampion(Champion champion)
   {
      base.RemoveSecondTeamChampion(champion);
      secondTeamChampionInInnerPoint.Remove(champion);
   }

   protected override void OnUpdate()
   {
      base.OnUpdate();
      if(!PhotonNetwork.IsMasterClient) return;

      for (int i = 0; i < firstTeamChampions.Count; i++)
      {
         var sqrMagnitude = (firstTeamChampions[i].transform.position - transform.position).sqrMagnitude;
         if (firstTeamChampionInInnerPoint.Contains(firstTeamChampions[i]))
         {
            if (sqrMagnitude >
                innerRangeSquared)
            {
               firstTeamChampionInInnerPoint.Remove(firstTeamChampions[i]);
               ResolveTeamSupremacy();
            }
         }
         else
         {
            if (sqrMagnitude <
                innerRangeSquared)
            {
               firstTeamChampionInInnerPoint.Add(firstTeamChampions[i]);
               ResolveTeamSupremacy();
            }
         }
      }
      for (int i = 0; i < secondTeamChampions.Count; i++)
      {
         var sqrMagnitude = (secondTeamChampions[i].transform.position - transform.position).sqrMagnitude;
         if (secondTeamChampionInInnerPoint.Contains(secondTeamChampions[i]))
         {
            if (sqrMagnitude >
                innerRangeSquared)
            {
               secondTeamChampionInInnerPoint.Remove(secondTeamChampions[i]);
               ResolveTeamSupremacy();
            }
         }
         else
         {
            if (sqrMagnitude <
                innerRangeSquared)
            {
               secondTeamChampionInInnerPoint.Add(secondTeamChampions[i]);
               ResolveTeamSupremacy();
            }
         }
      }

   }
}
    
}
