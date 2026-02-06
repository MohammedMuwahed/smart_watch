const SERVER_BASE = process.env.REACT_APP_SERVER_BASE || "https://your-public-host.example";
export async function setSleep(isSleeping){
  return fetch(`${SERVER_BASE}/update-sleep`, {
    method: "POST",
    headers: {"Content-Type":"application/json"},
    body: JSON.stringify({ isSleeping })
  });
}