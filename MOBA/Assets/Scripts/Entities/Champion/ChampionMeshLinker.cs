using System;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace Entities.Champion
{
    public class ChampionMeshLinker : MonoBehaviourPun
    {
        [SerializeField] private Renderer[] teamColorfulParts;
        public Animator animator;
        private static readonly int EmissionColor = Shader.PropertyToID("_EmissionColor");
        public Renderer championRenderer;

        public Texture[] championTextures;
        public void LinkTeamColor(Enums.Team team)
        {
            var color = Color.white;
            foreach (var tc in GameStateMachine.Instance.teamColors)
            {
                if (team != tc.team) continue;
                color = tc.color;
                break;
            }

            foreach (var rd in teamColorfulParts) {
                rd.material.color = color;
            }

            if (team == Enums.Team.Team1)
                championRenderer.material.mainTexture = championTextures[0];
            else  championRenderer.material.mainTexture = championTextures[1];

        }
    }
}