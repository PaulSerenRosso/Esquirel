using Photon.Pun;
using UnityEngine;

namespace GameStates.States
{
    public class PostGameState : GameState
    {
        public PostGameState(GameStateMachine sm) : base(sm) { }

        public override void StartState()
        {
            Time.timeScale = 0;
  
            Debug.Log(sm.winBySurrender);
            PostGameUIManager.Instance.DisplayPostGame(sm.winner, sm.winBySurrender);
        
        }

        public override void UpdateState() { }

        public override void ExitState() { }

        public override void OnAllPlayerReady()
        {
            sm.SwitchState(0);
        }
    }
}