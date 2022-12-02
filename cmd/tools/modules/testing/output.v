module testing

import time

pub enum MessageKind {
	ok
	fail
	skip
	info
	sentinel
}

pub struct LogMessage {
pub:
	flow_id string        // the messages of each thread, producing LogMessage, will have all the same unique flowid. Messages by other threads will have other flowid. If you use VJOBS=1 to serialise the execution, then all messages will have the same flowid.
	file    string        // the _test.v file that the message is about
	message string        // the actual message text; the result of the event, that the message describes; most reporters could ignore this, since it could be reconstructed by the other fields
	kind    MessageKind   // see the MessageKind declaration
	when    time.Time     // when was the message sent (messages are sent by the execution threads at the *end* of each event)
	took    time.Duration // the duration of the event, that this message describes
}

pub interface Reporter {
mut:
	session_start(message string, mut ts TestSession) // called once per test session, in the main thread, suitable for setting up supporting infrastructure.
	session_stop(message string, mut ts TestSession) // called once per test session, in the main thread, after everything else, suitable for summaries, creating .xml reports, uploads etc.
	worker_threads_start(files []string, mut ts TestSession) // called once per test session, in the main thread, right before all the worker threads start
	worker_threads_finish(mut ts TestSession) // called once per test session, in the main thread, right after all the worker threads finish
	//
	report(index int, log_msg LogMessage) // called once per each message, that will be shown (ok/fail/skip etc), only in the reporting thread.
	report_stop() // called just once after all messages are processed, only in the reporting thread, but before stop_session.
	//
	// TODO: reconsider, whether the next methods, should be kept for all reporters, or just moved inside the normal reporter, to simplify the interface
	progress(index int, message string)
	update_last_line(index int, message string)
	update_last_line_and_move_to_next(index int, message string)
	message(index int, message string)
	divider() // called to show a long ---------- horizontal line; can be safely ignored in most reporters; used in the main thread.
	list_of_failed_commands(cmds []string) // called after all testing is done, to produce a small summary that only lists the failed commands, so that they can be retried manually if needed, without forcing the user to scroll and find them.
}
