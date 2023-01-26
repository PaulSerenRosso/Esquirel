using UnityEngine;

namespace GameStates.States
{
    public class InGameState : GameState
    {
        public InGameState(GameStateMachine sm) : base(sm)
        {
        }

        private double timer;

        public override void StartState()
        {
            InputManager.EnablePlayerMap(true);
        }

        public override void UpdateState()
        {
            sm.OnUpdate?.Invoke();
            if (!sm.IsMaster) return;


            if (timer >= 1.0 / sm.tickRate)
            {
                timer -= 1.0 / sm.tickRate;
                sm.Tick();
            }
            else timer += Time.deltaTime;

        }

        public override void ExitState()
        {
        }

        public override void OnAllPlayerReady()
        {
        }

    }

}