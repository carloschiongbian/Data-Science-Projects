'use client'

import { FormEvent, useState } from "react";

export default function Home() {
  const [task, setTask] = useState("");
  const [tasks, setTasks] = useState<string[]>([]);

  function addTask(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const trimmedTask = task.trim();

    if (!trimmedTask) return;

    setTasks([...tasks, trimmedTask]);
    setTask("");
  }

  return (
    <main className="min-h-screen bg-zinc-100 px-4 py-16">
      <div className="mx-auto max-w-md rounded-lg bg-white p-6 shadow">
        <h1 className="mb-6 text-2xl font-bold text-zinc-900">To-do List</h1>

        <form onSubmit={addTask} className="mb-6 flex gap-2">
          <input
            type="text"
            value={task}
            onChange={(event) => setTask(event.target.value)}
            placeholder="Add a task"
            className="min-w-0 flex-1 rounded border border-zinc-300 px-3 py-2 text-zinc-900"
          />
          <button
            type="submit"
            className="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700"
          >
            Add
          </button>
        </form>

        <ul className="space-y-2">
          {tasks.map((item, index) => (
            <li
              key={`${item}-${index}`}
              className="flex items-center justify-between rounded bg-zinc-50 px-3 py-2 text-zinc-900"
            >
              <span>{item}</span>
              <button
                type="button"
                onClick={() =>
                  setTasks(tasks.filter((_, taskIndex) => taskIndex !== index))
                }
                className="text-sm text-red-600 hover:underline"
              >
                Remove
              </button>
            </li>
          ))}
        </ul>
      </div>
    </main>
  );
}
