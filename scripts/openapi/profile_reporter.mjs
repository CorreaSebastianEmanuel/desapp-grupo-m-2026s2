import {appendFileSync} from 'node:fs';
export default async function* (source) {
  for await (const event of source) {
    if (!['test:start', 'test:pass', 'test:fail'].includes(event.type)) continue;
    const {name, details} = event.data;
    const file = process.env.PROFILE_NODE_FILE;
    const state = event.type === 'test:start' ? 'started' : event.type === 'test:pass' && !event.data.skip && !event.data.todo ? 'passed' : 'failed';
    const base = {nonce: process.env.PROFILE_NONCE, runner: 'node', file, case_id: name};
    appendFileSync(process.env.PROFILE_EVENTS, JSON.stringify({...base, state})+'\n');
  }
}
