#!/usr/bin/env node
import { readFileSync, existsSync, readdirSync } from 'fs';
import { join } from 'path';
import { homedir } from 'os';

const CLAUDE_DIR = join(homedir(), '.claude');
const TASKS_DIR = join(CLAUDE_DIR, 'tasks');
const TEAMS_DIR = join(CLAUDE_DIR, 'teams');

function getTeamStatus() {
  if (!existsSync(TEAMS_DIR)) return null;
  const teams = readdirSync(TEAMS_DIR).filter(f => f.endsWith('.json'));
  if (teams.length === 0) return null;

  try {
    const teamFile = join(TEAMS_DIR, teams[0]);
    const team = JSON.parse(readFileSync(teamFile, 'utf8'));
    const teamName = team.name || teams[0].replace('.json', '');
    const members = team.members || [];
    return { name: teamName, memberCount: members.length, members };
  } catch { return null; }
}

function getTaskProgress(teamName) {
  if (!teamName) return null;
  const taskDir = join(TASKS_DIR, teamName);
  if (!existsSync(taskDir)) return null;

  try {
    const files = readdirSync(taskDir).filter(f => f.endsWith('.json'));
    let total = 0, completed = 0, inProgress = 0;
    for (const f of files) {
      const task = JSON.parse(readFileSync(join(taskDir, f), 'utf8'));
      total++;
      if (task.status === 'completed') completed++;
      else if (task.status === 'in_progress') inProgress++;
    }
    return { total, completed, inProgress };
  } catch { return null; }
}

function main() {
  const team = getTeamStatus();
  if (!team) {
    process.stdout.write('');
    return;
  }

  const tasks = getTaskProgress(team.name);
  const parts = [`❐ ${team.name}`];

  if (tasks && tasks.total > 0) {
    const pct = Math.round((tasks.completed / tasks.total) * 100);
    parts.push(`${tasks.completed}/${tasks.total} (${pct}%)`);
    if (tasks.inProgress > 0) parts.push(`▶ ${tasks.inProgress}`);
  }

  parts.push(`⚡${team.memberCount} agents`);
  process.stdout.write(parts.join(' · '));
}

main();
